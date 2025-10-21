<#
.SYNOPSIS
  Setup GitHub self-hosted Windows runner + install sqlcmd & ODBC 18.

.PARAMETER RepoUrl
  URL repo GitHub kamu, contoh: https://github.com/ORG/REPO

.PARAMETER Token
  Runner registration token (dari Repo → Settings → Actions → Runners → New self-hosted runner)

.PARAMETER Labels
  (Opsional) Label runner, contoh: "windows-db,self-hosted"

.PARAMETER InstallAsService
  (Switch) Install runner sebagai Windows Service & start

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\setup-selfhosted-runner.ps1 `
    -RepoUrl "https://github.com/ORG/REPO" `
    -Token "<TOKEN>" `
    -Labels "windows-db,self-hosted" `
    -InstallAsService
#>

param(
  [Parameter(Mandatory=$true)][string]$RepoUrl,
  [Parameter(Mandatory=$true)][string]$Token,
  [string]$Labels = "self-hosted,Windows",
  [switch]$InstallAsService
)

$ErrorActionPreference = "Stop"

# 1) Buat folder runner
$runnerRoot = "C:\actions-runner"
if (-not (Test-Path $runnerRoot)) { New-Item -ItemType Directory -Path $runnerRoot | Out-Null }
Set-Location $runnerRoot

# 2) Download & extract runner
$runnerVersion = "2.316.1"
$zip = "actions-runner-win-x64-$runnerVersion.zip"
$uri = "https://github.com/actions/runner/releases/download/v$runnerVersion/$zip"
if (-not (Test-Path $zip)) {
  Write-Host "Download $zip ..."
  Invoke-WebRequest -Uri $uri -OutFile $zip
}
Write-Host "Extracting..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory("$PWD\$zip", "$PWD", $true)

# 3) Install tools: sqlcmd & ODBC 18 (via winget)
Write-Host "Installing SQL Server Command Line Tools + ODBC via winget..."
winget install Microsoft.SQLServer.CommandLineTools --accept-package-agreements --accept-source-agreements -h 0
winget install Microsoft.ODBCDriverForSQLServer --accept-package-agreements --accept-source-agreements -h 0

# 4) Konfigurasi runner
$labelsArg = "--labels `"$Labels`""
$cmd = ".\config.cmd --url `"$RepoUrl`" --token `"$Token`" $labelsArg --unattended"
Write-Host "Configuring runner: $cmd"
cmd /c $cmd

# 5) Install sebagai service (opsional)
if ($InstallAsService) {
  Write-Host "Installing & starting runner service..."
  cmd /c ".\svc install"
  cmd /c ".\svc start"
  Write-Host "Runner service started."
} else {
  Write-Host "Run foreground: .\run.cmd (jalankan manual jika tidak pakai service)."
}

Write-Host "Done. Cek repo → Settings → Actions → Runners (harus Online)."
