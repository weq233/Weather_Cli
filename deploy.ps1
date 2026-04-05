# Weather_Cli Automated Deployment Script (Windows -> Debian 13)
# Usage: .\deploy.ps1 -DebianIP "192.168.121.100" -User "weq"

param(
    [Parameter(Mandatory=$true)]
    [string]$DebianIP,
    
    [Parameter(Mandatory=$false)]
    [string]$User = "weq",
    
    [Parameter(Mandatory=$false)]
    [string]$DeployMethod = "binary",  # binary or docker
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Weather_Cli Deployment Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ProjectPath = $PSScriptRoot
$BinaryName = "weather-cli"
$RemotePath = "/home/$User"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

# Check if Go is installed
if (-not (Get-Command "go" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Go not found, please install Go 1.21+" -ForegroundColor Red
    exit 1
}
Write-Host "PASS: Go version: $(go version)" -ForegroundColor Green

# Check if SSH/SCP is available
if (-not (Get-Command "scp" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: SCP command not found, please install OpenSSH client" -ForegroundColor Red
    Write-Host "   Run: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0" -ForegroundColor Yellow
    exit 1
}
Write-Host "PASS: SCP available" -ForegroundColor Green

Write-Host ""
Write-Host "[2/5] Compiling Linux binary..." -ForegroundColor Yellow

if (-not $SkipBuild) {
    # Set cross-compilation environment variables
    $env:CGO_ENABLED = "0"
    $env:GOOS = "linux"
    $env:GOARCH = "amd64"
    
    Write-Host "   Target platform: linux/amd64" -ForegroundColor Gray
    Write-Host "   CGO: disabled (static linking)" -ForegroundColor Gray
    
    # Compile
    try {
        go build -ldflags="-w -s" -o "$BinaryName" "$ProjectPath\cmd\main.go" "$ProjectPath\cmd\root.go"
        Write-Host "PASS: Compilation successful: $BinaryName" -ForegroundColor Green
        
        # Verify file
        $FileInfo = Get-Item "$BinaryName"
        Write-Host "   File size: $([math]::Round($FileInfo.Length / 1MB, 2)) MB" -ForegroundColor Gray
    }
    catch {
        Write-Host "FAIL: Compilation failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "SKIP: Build step skipped" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/5] Testing local functionality..." -ForegroundColor Yellow

try {
    # Note: Linux binary cannot run on Windows, just basic check
    if (Test-Path "$BinaryName") {
        Write-Host "PASS: Binary file exists" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Binary file not found" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "WARNING: Cannot test Linux binary on Windows (expected)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[4/5] Transferring to Debian 13 ($DebianIP)..." -ForegroundColor Yellow

try {
    # Transfer binary file
    Write-Host "   Transferring $BinaryName to ${User}@${DebianIP}:${RemotePath}/" -ForegroundColor Gray
    
    scp "$BinaryName" "${User}@${DebianIP}:${RemotePath}/$BinaryName"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASS: Transfer successful" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Transfer failed" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "FAIL: Transfer error: $_" -ForegroundColor Red
    Write-Host "   Tip: Ensure Debian is accessible and SSH service is running" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[5/5] Setting permissions on remote server..." -ForegroundColor Yellow

try {
    # Execute remote commands via SSH
    ssh "${User}@${DebianIP}" "chmod +x ${RemotePath}/${BinaryName}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASS: Permissions set successfully" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Permission setting may have failed, please manually execute: chmod +x ${RemotePath}/${BinaryName}" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "WARNING: Cannot automatically set permissions, please execute manually on Debian:" -ForegroundColor Yellow
    Write-Host "   chmod +x ${RemotePath}/${BinaryName}" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[7/7] Configuring permanent environment variables..." -ForegroundColor Yellow

try {
    # Configure permanent environment variables on remote server
    ssh "${User}@${DebianIP}" @"
# Add to .bashrc if not already present
grep -q 'WEATHER_API_KEY' ~/.bashrc || {
    echo '' >> ~/.bashrc
    echo '# Weather CLI Configuration' >> ~/.bashrc
    echo 'export WEATHER_API_KEY=`"f694dcb7ce394ffe93408aa83f92a54e`"' >> ~/.bashrc
    echo 'export WEATHER_API_HOST=`"p54nmuk5rq.re.qweatherapi.com`"' >> ~/.bashrc
}

# Add convenient aliases
grep -q 'alias weather=' ~/.bashrc || {
    echo '' >> ~/.bashrc
    echo '# Weather CLI Aliases' >> ~/.bashrc
    echo 'alias weather=`"/home/weq/weather-cli`"' >> ~/.bashrc
    echo 'alias weather-bj=`"weather --city Beijing`"' >> ~/.bashrc
    echo 'alias weather-sh=`"weather --city Shanghai`"' >> ~/.bashrc
    echo 'alias weather-gz=`"weather --city Guangzhou`"' >> ~/.bashrc
}

# Reload bashrc
source ~/.bashrc
"@

    Write-Host "PASS: Environment variables and aliases configured successfully" -ForegroundColor Green
    Write-Host "   You can now use these commands on Debian:" -ForegroundColor Gray
    Write-Host "     weather --city Beijing" -ForegroundColor Cyan
    Write-Host "     weather-bj              (shortcut for Beijing)" -ForegroundColor Cyan
    Write-Host "     weather-sh              (shortcut for Shanghai)" -ForegroundColor Cyan
}
catch {
    Write-Host "WARNING: Could not configure environment automatically" -ForegroundColor Yellow
    Write-Host "   Please run the configuration commands manually on Debian" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. SSH to Debian: ssh ${User}@${DebianIP}" -ForegroundColor White
Write-Host "2. Run test: ./run.sh test" -ForegroundColor White
Write-Host "3. Query weather: ./run.sh query --city Beijing" -ForegroundColor White
Write-Host ""
Write-Host "Or one-click test:" -ForegroundColor Cyan
Write-Host "ssh ${User}@${DebianIP} 'export WEATHER_API_KEY=p54nmuk5rq && /home/${User}/weather-cli --city Beijing'" -ForegroundColor Gray
Write-Host ""
