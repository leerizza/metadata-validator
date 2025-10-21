# PR Validate → Auto-Deploy to STAGING → Auto-Comment on PR

Workflow (`.github/workflows/validate-staging-comment.yml`):
1. **Validate** changed SQL (naming + tipe data) pada **Pull Request**.
2. Jika **PASS**, otomatis **Deploy ke STAGING** (folder `deploy/` urut nama file).
3. Bot **komentar ke PR** berisi ringkasan file yang dieksekusi + tabel yang baru dibuat/diubah (30 menit terakhir).

## Cara pakai
1. Copy isi ZIP ke root repo, commit & push.
2. Buat **Actions Secrets** (Repo → Settings → Secrets and variables → Actions):
   - `STG_DB_HOST`, `STG_DB_PORT`, `STG_DB_NAME`, `STG_DB_USER`, `STG_DB_PASSWORD`
3. Buka **Pull Request** yang mengubah file `.sql` → workflow jalan otomatis.

> Token `GITHUB_TOKEN` otomatis tersedia untuk menulis komentar ke PR (tidak perlu secret tambahan).

## Koneksi ke SQL Server
- **Direkomendasikan:** **SQL Authentication** (`-U` / `-P`). Windows Integrated Auth tidak tersedia di runner GitHub hosted; kalau perlu Integrated, gunakan **self-hosted Windows runner** yang berada dalam domain yang sama.
- **Firewall/VPN:** Pastikan runner bisa mengakses host DB (allowlist IP GitHub hosted, atau gunakan **self-hosted runner** di network internal/VPN).
- **TLS:** Workflow memakai ODBC18 + `-C` dan `SQLCMDTRUSTSERVERCERT=true` untuk mempermudah TLS. Jika sertifikat valid publik, Anda dapat menonaktifkan trust server cert dan membiarkan verifikasi default.
- **Azure SQL:** Ganti host/port sesuai Azure SQL. Jika menggunakan Azure AD auth, sesuaikan perintah `sqlcmd` (opsi `-G`). PoC ini default SQL Auth.

## SQL idempotent
Gunakan `IF NOT EXISTS` untuk `CREATE`, dan `COL_LENGTH` untuk `ALTER`, agar aman bila dijalankan ulang.

## Struktur
```
.
├─ rules.yml
├─ validate_sql.py
├─ requirements.txt
├─ deploy/
│  ├─ 001_create_tables.sql
│  └─ 002_alter_tables.sql
└─ .github/workflows/
   └─ validate-staging-comment.yml
```

## Local testing
```
pip install -r requirements.txt
python validate_sql.py --junit report.xml
```
