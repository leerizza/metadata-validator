#!/usr/bin/env python3
import os, re, sys, glob, yaml, argparse, xml.etree.ElementTree as ET
from pathlib import Path
from typing import List, Tuple

CREATE_TABLE_RE = re.compile(r'(?is)\bCREATE\s+TABLE\b\s+([A-Za-z0-9_\.\[\]]+)')

def load_rules(path: str = "rules.yml") -> dict:
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}

def list_sql_files(rules: dict, only_changed: List[str] = None) -> List[str]:
    if only_changed:
        return [f for f in only_changed if f.endswith(".sql") and Path(f).is_file()]
    include = rules.get("files", {}).get("include_globs", ["**/*.sql"])
    exclude = rules.get("files", {}).get("exclude_globs", [])
    files = set()
    for pat in include:
        for p in glob.glob(pat, recursive=True):
            if Path(p).is_file():
                files.add(os.path.normpath(p))
    for epat in exclude:
        for p in glob.glob(epat, recursive=True):
            files.discard(os.path.normpath(p))
    return sorted(files)

def normalize_table_name(raw: str) -> str:
    return raw.strip().replace("[", "").replace("]", "")

def table_basename(name: str) -> str:
    return normalize_table_name(name).split(".")[-1]

def find_create_tables(sql_text: str) -> List[str]:
    return [m.group(1) for m in CREATE_TABLE_RE.finditer(sql_text)]

def check_table_name(name: str, rules: dict) -> List[str]:
    errs = []
    tn = rules.get("table_name", {})
    pattern = tn.get("pattern", r'^[a-z][a-z0-9_]*$')
    min_len = int(tn.get("min_length", 1))
    max_len = int(tn.get("max_length", 128))
    allow_schema = bool(tn.get("allow_schema_prefix", True))
    allowed_prefixes = tn.get("allowed_prefixes", [])
    forbidden_substrings = tn.get("forbidden_substrings", [])

    name_norm = normalize_table_name(name)
    if not allow_schema and "." in name_norm:
        errs.append(f"Table `{name_norm}` tidak boleh pakai schema prefix.")

    base = table_basename(name_norm)
    if not re.match(pattern, base):
        errs.append(f"Nama tabel `{base}` tidak sesuai pattern `{pattern}`.")
    if len(base) < min_len or len(base) > max_len:
        errs.append(f"Nama tabel `{base}` harus {min_len}–{max_len} karakter.")
    if allowed_prefixes and not any(base.startswith(p) for p in allowed_prefixes):
        errs.append(f"Nama tabel `{base}` harus diawali salah satu prefix: {allowed_prefixes}")
    for sub in forbidden_substrings:
        if sub in base:
            errs.append(f"Nama tabel `{base}` mengandung substring terlarang: `{sub}`")

    return errs

def check_datatypes(sql_text: str, rules: dict) -> List[str]:
    errs = []
    dt = rules.get("datatype", {})
    disallowed = dt.get("disallowed_regex", [])
    varchar_max = dt.get("varchar_max_length", None)
    allow_unbounded = dt.get("allow_unbounded_types", True)

    for rx in disallowed:
        if re.search(rx, sql_text, flags=re.IGNORECASE):
            errs.append(f"Terdeteksi tipe data terlarang: match `{rx}`")

    if varchar_max is not None:
        for m in re.finditer(r'(?i)\b(n?varchar)\s*\(\s*(\d+)\s*\)', sql_text):
            if int(m.group(2)) > int(varchar_max):
                errs.append(f"{m.group(1).upper()}({m.group(2)}) melebihi batas {varchar_max}")

    if not allow_unbounded:
        for m in re.finditer(r'(?i)\b(n?varchar)\b(?!\s*\()', sql_text):
            errs.append(f"Tipe {m.group(1).upper()} tanpa panjang tidak diizinkan.")

    return errs

def to_junit(all_errs: List[Tuple[str, List[str]]], out_path: str):
    tests = max(1, len(all_errs)) if all_errs else 1
    testsuite = ET.Element("testsuite", name="metadata-validator", tests=str(tests))
    if not all_errs:
        ET.SubElement(testsuite, "testcase", classname="validator", name="all_passed")
    else:
        for f, errs in all_errs:
            name = f.replace("/", ".")
            tc = ET.SubElement(testsuite, "testcase", classname="validator", name=name)
            if errs:
                failure = ET.SubElement(tc, "failure", message=f"{len(errs)} violation(s)")
                failure.text = "\n".join(f"- {e}" for e in errs)
    ET.ElementTree(testsuite).write(out_path, encoding="utf-8", xml_declaration=True)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rules", default="rules.yml", help="Path rules.yml")
    ap.add_argument("--junit", default="", help="Path output JUnit XML (opsional)")
    ap.add_argument("--files", nargs="*", default=None, help="Batasi ke file tertentu")
    args = ap.parse_args()

    rules = load_rules(args.rules)
    files = list_sql_files(rules, args.files)

    if not files:
        print("Tidak ada file SQL yang dipindai.")
        if args.junit:
            to_junit([], args.junit)
        sys.exit(0)

    all_errs = []
    for f in files:
        text = Path(f).read_text(encoding="utf-8", errors="ignore")
        file_errs = []
        tables = find_create_tables(text)
        for t in tables:
            file_errs += check_table_name(t, rules)
        file_errs += check_datatypes(text, rules)
        if file_errs:
            all_errs.append((f, file_errs))

    if all_errs:
        print("❌ Metadata validation FAILED\n")
        for f, errs in all_errs:
            print(f"File: {f}")
            for e in errs:
                print(f"  - {e}")
            print("")
        if args.junit:
            to_junit(all_errs, args.junit)
        sys.exit(1)
    else:
        print("✅ Metadata validation PASSED")
        if args.junit:
            to_junit([], args.junit)
        sys.exit(0)

if __name__ == "__main__":
    main()
