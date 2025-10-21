import sys, re
from pathlib import Path
import yaml

ALLOWED_TYPES = {
    "tinyint","smallint","int","bigint","real","float","decimal","numeric","bit",
    "date","time","smalldatetime","datetime","datetime2","datetimeoffset",
    "char","varchar","nchar","nvarchar","binary","varbinary","uniqueidentifier"
}
REQUIRES_LEN_OR_PREC = {
    "char","varchar","nchar","nvarchar","binary","varbinary",
    "decimal","numeric","datetime2","datetimeoffset","time"
}
NAME_RE  = re.compile(r"^[a-z][a-z0-9_]*$")
TABLE_RE = re.compile(r"^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$")

def fail(msg):
    print(f"❌ {msg}")
    sys.exit(1)

def ok(msg):
    print(f"✅ {msg}")

def normalize_type(t: str) -> str:
    t = t.strip().lower()
    if "(max)" in t:  # hard rule
        fail("Tipe data dengan (MAX) tidak diizinkan (gunakan panjang eksplisit).")

    m = re.match(r"^([a-z]+)\s*\((.+)\)$", t)
    if m:
        base, arg = m.group(1), m.group(2).strip()
        if base not in ALLOWED_TYPES:
            fail(f"Tipe data '{base}' tidak termasuk whitelist.")
        if base in {"char","varchar","nchar","nvarchar","binary","varbinary"}:
            if not re.fullmatch(r"\d{1,4}", arg):
                fail(f"Panjang untuk {base} harus angka, contoh: {base}(200).")
        elif base in {"decimal","numeric"}:
            if not re.fullmatch(r"\d{1,2}\s*,\s*\d{1,2}", arg):
                fail(f"{base} harus (precision, scale), contoh: decimal(18,2).")
        elif base in {"datetime2","datetimeoffset","time"}:
            if not re.fullmatch(r"\d{1,2}", arg):
                fail(f"{base} harus (scale) 0-7, contoh: {base}(3).")
        return f"{base}({arg})"
    else:
        base = t
        if base not in ALLOWED_TYPES:
            fail(f"Tipe data '{base}' tidak termasuk whitelist.")
        if base in REQUIRES_LEN_OR_PREC:
            fail(f"Tipe data '{base}' harus menyertakan panjang/precision, mis. {base}(...).")
        return base

def render_create_sql(meta: dict) -> str:
    table = meta.get("table")
    if not table or not TABLE_RE.match(table):
        fail("Nama tabel harus 'schema.table' huruf kecil/angka/underscore. Contoh: dbo.customer")
    schema, tbl = table.split(".")
    if not meta.get("columns"):
        fail("Metadata harus punya minimal 1 kolom.")

    cols_sql = []
    for col in meta["columns"]:
        name = col["name"]
        if not NAME_RE.match(name):
            fail(f"Nama kolom tidak valid: {name}")
        dtype = normalize_type(col["type"])
        nullable = col.get("nullable", True)
        cols_sql.append(f"    [{name}] {dtype} {'NULL' if nullable else 'NOT NULL'}")

    pk_sql = ""
    if meta.get("primary_key"):
        for k in meta["primary_key"]:
            if not NAME_RE.match(k):
                fail(f"Nama kolom PK tidak valid: {k}")
        pk_cols = ", ".join(f"[{k}]" for k in meta["primary_key"])
        pk_sql = f",\n    CONSTRAINT [PK_{tbl}] PRIMARY KEY CLUSTERED ({pk_cols})"

    idx_sql = []
    for idx in meta.get("indexes") or []:
        iname = idx["name"]
        if not NAME_RE.match(iname):
            fail(f"Nama index tidak valid: {iname}")
        cols = idx["columns"]
        for c in cols:
            if not NAME_RE.match(c): fail(f"Nama kolom index tidak valid: {c}")
        unique = "UNIQUE " if idx.get("unique") else ""
        cols_join = ", ".join(f"[{c}]" for c in cols)
        idx_sql.append(f"CREATE {unique}NONCLUSTERED INDEX [{iname}] ON [{schema}].[{tbl}] ({cols_join});")

    prelude = f"""
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'{schema}')
BEGIN
    EXEC('CREATE SCHEMA [{schema}] AUTHORIZATION dbo;');
END
""".strip()

    create = f"""
IF OBJECT_ID(N'[{schema}].[{tbl}]', 'U') IS NULL
BEGIN
    PRINT 'Creating [{schema}].[{tbl}]';
    CREATE TABLE [{schema}].[{tbl}] (
{",\n".join(cols_sql)}{pk_sql}
    );
END
ELSE
BEGIN
    RAISERROR('Tabel [{schema}].[{tbl}] sudah ada.', 16, 1);
END
""".strip()

    body = prelude + "\n" + create
    if idx_sql:
        body += "\n" + "\n".join(idx_sql)
    return body

def main():
    if len(sys.argv) < 3:
        print("Usage: python scripts/metadata_validate_and_render.py <tables_dir> <out_dir>")
        sys.exit(2)

    src = Path(sys.argv[1]); out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
    metas = list(src.glob("*.yml")) + list(src.glob("*.yaml"))
    if not metas: fail("Tidak ada file metadata (*.yml) di folder 'tables/'.")

    for f in metas:
        meta = yaml.safe_load(f.read_text(encoding="utf-8"))
        sql = render_create_sql(meta)
        schema, tbl = meta["table"].split(".")
        out_file = out / f"{schema}_{tbl}.sql"
        out_file.write_text(sql, encoding="utf-8")
        ok(f"{f.name} valid. SQL => {out_file}")

if __name__ == "__main__":
    main()
