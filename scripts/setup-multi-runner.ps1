<#
Skrip auto setup multi self-hosted runner (Windows) + firewall + SQLCMD autodetect.

Contoh:
.\setup-multi-runner.ps1 `
  -RepoUrl "https://github.com/leerizza/metadata-validator" `
  -Token "<RUNNER_REG_TOKEN>" `
  -Count 2 `
  -SetRepoVariable:$true `
  -Pat "<GITHUB_PAT_SCOPE_actions:write>"
#>

param(
  [Parameter(Mandatory=$true)][string]$RepoUrl,
  [Parameter(Mandatory=$true)][string]$Token,
  [int]$Count = 1,
  [string]$RunnerBaseName = "$($env:COMPUTERNAME)-runner",
  [string]$Labels = "self-hosted,Windows",
  [string]$RunnerVersion = "2.329.0",
  [bool]$InstallAsService = $true,
  [bool]$SetRepoVariable = $false,
  [string]$Pat
)

function Write-Ok($msg){ Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info($msg){ Write-Host "• $msg" -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host "❌ $msg" -ForegroundColor Red }

# -- Pastikan TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -- Parse owner/repo
if ($RepoUrl -notmatch 'https://github.com/([^/]+)/([^/]+)') { throw "RepoUrl invalid" }
$Owner = $Matches[1]; $Repo = $Matches[2]

# -- Auto detect sqlcmd
function Find-Sqlcmd {
  $paths = @(
    "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
    "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\160\Tools\Binn\sqlcmd.exe",
    "C:\Program Files\Microsoft SQL Server\150\Tools\Binn\sqlcmd.exe",
    "C:\Program Files\Microsoft SQL Server\140\Tools\Binn\sqlcmd.exe"
  )
  foreach ($p in $paths){ if (Test-Path $p){ return $p } }
  $cmd = (where.exe sqlcmd 2>$null)
  if ($cmd){ return $cmd }
  return $null
}

$sqlcmd = Find-Sqlcmd
if (-not $sqlcmd){ Write-Err "sqlcmd.exe tidak ditemukan"; exit 1 }
Write-Ok "sqlcmd ditemukan di: $sqlcmd"

# -- (opsional) buka firewall untuk outbound 443
Write-Info "Memastikan Firewall rule outbound 443 terbuka..."
try {
  netsh advfirewall firewall add rule name="Allow_GitHub_Actions_Outbound_443" dir=out action=allow protocol=TCP localport=443 >$null 2>&1
  Write-Ok "Firewall rule OK."
} catch { Write-Warning "Gagal buat rule firewall: $_" }

# -- Download runner zip
$runnerZip = "actions-runner-win-x64-$RunnerVersion.zip"
if (-not (Test-Path $runnerZip)){
  Write-Info "Download runner $RunnerVersion..."
  Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$RunnerVersion/$runnerZip" -OutFile $runnerZip
}

for ($i=1; $i -le $Count; $i++){
  $name = "$RunnerBaseName-$i"
  $root = "actions-runner-$i"
  Write-Info "Setup runner $i ($name)..."

  if (-not (Test-Path $root)){ New-Item -ItemType Directory -Path $root | Out-Null }
  Expand-Archive -Path $runnerZip -DestinationPath $root -Force
  Push-Location $root

  # tulis .env
  "SQLCMD_EXE=$sqlcmd" | Out-File ".env" -Encoding ascii

  & .\config.cmd --url $RepoUrl --token $Token --name $name --labels $Labels --unattended --replace --work "_work"

  if ($InstallAsService){
    & .\svc install
    & .\svc start
  }

  Pop-Location
  Write-Ok "Runner $name aktif."
}

# -- (opsional) Set Repo Variable SQLCMD_EXE via GitHub API
if ($SetRepoVariable -and $Pat){
  $uri = "https://api.github.com/repos/$Owner/$Repo/actions/variables/SQLCMD_EXE"
  $headers = @{
    "Accept"="application/vnd.github+json"
    "Authorization"="Bearer $Pat"
    "User-Agent"="setup-multi-runner"
  }
  $body = @{ name="SQLCMD_EXE"; value=$sqlcmd } | ConvertTo-Json
  try {
    Invoke-RestMethod -Method PATCH -Uri $uri -Headers $headers -Body $body -ContentType "application/json" | Out-Null
    Write-Ok "Repo Variable SQLCMD_EXE di-update."
  } catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 404){
      Invoke-RestMethod -Method PUT -Uri $uri -Headers $headers -Body $body -ContentType "application/json" | Out-Null
      Write-Ok "Repo Variable SQLCMD_EXE dibuat baru."
    } else {
      Write-Err $_
    }
  }
}

Write-Ok "Semua runner ($Count) telah aktif dan siap menerima job."
