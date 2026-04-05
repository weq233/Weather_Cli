# SSH Key Setup Script for Weather_Cli Deployment
# Usage: .\setup-ssh-key.ps1 -DebianIP "192.168.121.100" -DebianUser "weq"

param(
    [Parameter(Mandatory=$true)]
    [string]$DebianIP,
    
    [Parameter(Mandatory=$false)]
    [string]$DebianUser = "weq"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SSH Key Authentication Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check and generate SSH key
Write-Host "[1/4] Checking SSH key..." -ForegroundColor Yellow
$sshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519.pub"

if (Test-Path $sshKeyPath) {
    Write-Host "PASS: SSH public key found: $sshKeyPath" -ForegroundColor Green
} else {
    Write-Host "INFO: No SSH key found, generating new one..." -ForegroundColor Yellow
    
    # Generate new key
    try {
        ssh-keygen -t ed25519 -C "weather-cli-deploy" -f "$env:USERPROFILE\.ssh\id_ed25519" -N '""'
        Write-Host "PASS: SSH key generated successfully" -ForegroundColor Green
    } catch {
        Write-Host "FAIL: Failed to generate SSH key: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Display public key
Write-Host ""
Write-Host "[2/4] Public key content:" -ForegroundColor Yellow
$publicKey = Get-Content $sshKeyPath
Write-Host $publicKey -ForegroundColor Gray

# Step 3: Copy key to Debian
Write-Host ""
Write-Host "[3/4] Copying public key to Debian ($DebianIP)..." -ForegroundColor Yellow

try {
    # Try ssh-copy-id first
    Write-Host "   Trying ssh-copy-id..." -ForegroundColor Gray
    ssh-copy-id "${DebianUser}@${DebianIP}"
    Write-Host "PASS: Key copied using ssh-copy-id" -ForegroundColor Green
} catch {
    Write-Host "   Falling back to manual method..." -ForegroundColor Gray
    
    try {
        # Manual copy method
        $copyCommand = "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
        type $sshKeyPath | ssh "${DebianUser}@${DebianIP}" $copyCommand
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PASS: Key copied manually" -ForegroundColor Green
        } else {
            throw "Manual copy failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Host "FAIL: Could not copy key to Debian: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual setup instructions:" -ForegroundColor Yellow
        Write-Host "1. Copy the public key above" -ForegroundColor White
        Write-Host "2. SSH to Debian: ssh ${DebianUser}@${DebianIP}" -ForegroundColor White
        Write-Host "3. Run these commands on Debian:" -ForegroundColor White
        Write-Host "   mkdir -p ~/.ssh" -ForegroundColor Gray
        Write-Host "   echo '$publicKey' >> ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host "   chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys" -ForegroundColor Gray
        exit 1
    }
}

# Step 4: Test connection
Write-Host ""
Write-Host "[4/4] Testing passwordless SSH..." -ForegroundColor Yellow

try {
    $testResult = ssh "${DebianUser}@${DebianIP}" "echo 'SUCCESS'" 2>&1
    if ($testResult -match "SUCCESS") {
        Write-Host "PASS: Passwordless SSH working!" -ForegroundColor Green
    } else {
        throw "Test failed"
    }
} catch {
    Write-Host "WARNING: SSH may still require password. Please verify manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "SSH Key Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now use:" -ForegroundColor Cyan
Write-Host "  ssh ${DebianUser}@${DebianIP}" -ForegroundColor White
Write-Host ""
Write-Host "And deploy without password:" -ForegroundColor Cyan
Write-Host "  .\deploy.ps1 -DebianIP `"${DebianIP}`"" -ForegroundColor White
Write-Host ""
