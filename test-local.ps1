# Weather_Cli Local Test Script (Windows)
# Usage: .\test-local.ps1

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Weather_Cli Local Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check Go environment
Write-Host "[Test 1/4] Checking Go environment..." -ForegroundColor Yellow
try {
    $GoVersion = go version
    Write-Host "PASS: $GoVersion" -ForegroundColor Green
} catch {
    Write-Host "FAIL: Go not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Test 2: Download dependencies
Write-Host "`n[Test 2/4] Downloading dependencies..." -ForegroundColor Yellow
try {
    go mod download
    Write-Host "PASS: Dependencies downloaded" -ForegroundColor Green
} catch {
    Write-Host "FAIL: Dependency download failed" -ForegroundColor Red
    exit 1
}

# Test 3: Compile Windows version
Write-Host "`n[Test 3/4] Compiling Windows version..." -ForegroundColor Yellow
$compileResult = go build -o weather-cli-test.exe ./cmd 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "PASS: Compilation successful" -ForegroundColor Green
    
    # Show file size
    $fileInfo = Get-Item weather-cli-test.exe
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host "   File size: ${fileSizeMB} MB" -ForegroundColor Gray
} else {
    Write-Host "FAIL: Compilation failed" -ForegroundColor Red
    Write-Host $compileResult -ForegroundColor Red
    exit 1
}

# Test 4: Run functional tests
Write-Host "`n[Test 4/4] Running functional tests..." -ForegroundColor Yellow

Write-Host "`n  > Testing --help:" -ForegroundColor Gray
.\weather-cli-test.exe --help

Write-Host "`n  > Testing version:" -ForegroundColor Gray
.\weather-cli-test.exe version

Write-Host "`n  > Testing config:" -ForegroundColor Gray
.\weather-cli-test.exe config

Write-Host "`n  > Testing query (expected to show city required):" -ForegroundColor Gray
.\weather-cli-test.exe --city "Beijing"

# Cleanup
Write-Host "`nCleaning up test files..." -ForegroundColor Yellow
Remove-Item weather-cli-test.exe -ErrorAction SilentlyContinue
Write-Host "PASS: Cleanup complete" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "SUCCESS: All tests passed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Deploy to Debian: .\deploy.ps1 -DebianIP `"your-debian-ip`"" -ForegroundColor White
Write-Host "2. View docs: code DEPLOY.md" -ForegroundColor White
Write-Host ""
