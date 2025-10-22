<# 
.SYNOPSIS
  Bootstrap GitHub Actions self-hosted Windows runner + kebutuhan dasar.

.PARAMETER RepoUrl
  URL repo GitHub (https://github.com/<org>/<repo>)

.PARAMETER Token
  Token pendaftaran runner dari Settings → Actions → Runners → New self-hosted runner

.PARAMETER RunnerName
  Nama runner. Default: <hostname>-win

.PARAMETER Labels
  Label runner, koma-sep. Default: "self-hosted,Windows"

.PARAMETER RunnerVersion
  Versi runner. Default: 2.329.0 (boleh ganti jika perlu)

.PARAMETER InstallAsService
  Install runner sebagai Windows Service (default: $true)

.PARAMETER WorkDir
  Folder kerja runner (_work). Default: _work

.PARAMETER SqlcmdPath
  Path ke sqlcmd.exe. Jika diisi, akan disimpan ke .env (agar dipakai job).

.PARAMETER PythonPath
  Path ke python.exe yang sudah terpasang (opsional). Jika diisi, ikut dimasukkan ke .env dan PATH runner.

.EXAMPLE
  .\setup-selfhosted-runner.ps1 `
    -RepoUrl "https://github.com/leerizza/metadata-validator" `
    -Token "<TOKEN_DARI_GITHUB>" `
    -SqlcmdPath "C:\Program Files\SqlCmd\sqlcmd.exe"
#>

param(
  [Parameter(Mandatory=$true)][string]$RepoUrl,
  [Parameter(Mandatory=$true)][string]$Token,
  [string]$RunnerName = "$($env:COMPUTERNAME)-win",
  [string]$Labels = "self-hosted,Windows",
  [string]$RunnerVersion = "2.329.0",
  [bool]$InstallAsService = $true,
  [string]$WorkDir = "_work",
  [string]$SqlcmdPath,
  [string]$PythonPath
)

# --- Safety & UX -------------------------------------------------------------
$ErrorActionPreference = "Stop"
Write-Host "▶ Starting self-hosted runner setup..." -ForegroundColor Cyan

# 1) Pastikan PowerShell bisa jalanin script
try {
  $current = Get-ExecutionPolicy -Scope LocalMachine -ErrorAction SilentlyContinue
  if ($current -ne 'RemoteSigned' -and $current -ne 'Bypass') {
    Write-Host "• Setting ExecutionPolicy to RemoteSigned (LocalMachine)..." -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
  }
} catch { Write-Warning $_ }

# 2) Enable TLS 1.2 untuk download
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3) Siapkan folder runner
$runnerRoot = Join-Path $PWD "actions-runner"
if (-not (Test-Path $runnerRoot)) {
  New-Item -ItemType Directory -Path $runnerRoot | Out-Null
}
Set-Location $runnerRoot

# 4) Download & extract runner
$zip = "actions-runner-win-x64-$RunnerVersion.zip"
$url = "https://github.com/actions/runner/releases/download/v$RunnerVersion/$zip"
if (-not (Test-Path $zip)) {
  Write-Host "• Downloading runner $RunnerVersion ..." -ForegroundColor Yellow
  Invoke-WebRequest -Uri $url -OutFile $zip
}
Write-Host "• Extracting..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory($zip, $runnerRoot, $true)

# 5) Buat .env (optional) agar env ada untuk semua job di runner ini
#    (doc: actions runner supports .env in runner root)
$envFile = Join-Path $runnerRoot ".env"
$envLines = @()
if ($SqlcmdPath) {
  if (-not (Test-Path $SqlcmdPath)) { throw "SqlcmdPath not found: $SqlcmdPath" }
  $envLines += "SQLCMD_EXE=$SqlcmdPath"
}
if ($PythonPath) {
  if (-not (Test-Path $PythonPath)) { throw "PythonPath not found: $PythonPath" }
  $envLines += "PYTHON_EXE=$PythonPath"
  # Tambah parent folder python ke PATH runner service
  $envLines += "PATH=$([IO.Path]::GetDirectoryName($PythonPath));%PATH%"
}
if ($envLines.Count -gt 0) {
  Write-Host "• Writing .env for runner..." -ForegroundColor Yellow
  Set-Content -Path $envFile -Value ($envLines -join [Environment]::NewLine) -Encoding Ascii
}

# 6) Konfigurasi runner
$cfgArgs = @(
  "--url", $RepoUrl,
  "--token", $Token,
  "--name", $RunnerName,
  "--labels", $Labels,
  "--work", $WorkDir,
  "--unattended",
  "--replace"
)
Write-Host "• Configuring runner..." -ForegroundColor Yellow
& .\config.cmd @cfgArgs

# 7) Install sebagai service (opsional)
if ($InstallAsService) {
  Write-Host "• Installing and starting service..." -ForegroundColor Yellow
  & .\svc install
  & .\svc start
  Write-Host "✅ Runner installed as service: listening for jobs." -ForegroundColor Green
} else {
  Write-Host "• Running interactively (console). Close window to stop." -ForegroundColor Yellow
  & .\run.cmd
}

# 8) Info tambahan
Write-Host ""
Write-Host "Done. Tips:" -ForegroundColor Cyan
Write-Host " - Repo Variables → set SQLCMD_EXE to the same path for portability (optional)."
Write-Host " - Repo Secrets → STG_DB_HOST/PORT/NAME/USER/PASSWORD."
Write-Host " - Actions → Runners: should show '$RunnerName' online with labels: $Labels."
