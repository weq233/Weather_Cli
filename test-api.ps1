# Weather API Test Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Weather API Local Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if compiled
if (-Not (Test-Path ".\weather-api.exe")) {
    Write-Host "Compiling API service..." -ForegroundColor Yellow
    go build -o weather-api.exe ./cmd/api
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[FAIL] Compilation failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] Compilation successful" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting API service..." -ForegroundColor Yellow
Write-Host "Tip: Press Ctrl+C to stop the service" -ForegroundColor Gray
Write-Host ""

# Set environment variables
$env:GIN_MODE = "debug"
$env:API_PORT = "8080"

# Start API service (background)
$process = Start-Process -FilePath ".\weather-api.exe" -PassThru -NoNewWindow

# Wait for service to start
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing API Endpoints" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test health check
Write-Host "1. Testing health check endpoint..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method Get
    Write-Host "   [OK] Health check successful" -ForegroundColor Green
    Write-Host "   Response: $($healthResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   [FAIL] Health check failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test version info
Write-Host "2. Testing version endpoint..." -ForegroundColor Yellow
try {
    $versionResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/version" -Method Get
    Write-Host "   [OK] Version query successful" -ForegroundColor Green
    Write-Host "   Response: $($versionResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   [FAIL] Version query failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test weather query
Write-Host "3. Testing weather query (Beijing)..." -ForegroundColor Yellow
try {
    $weatherResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/weather?city=Beijing" -Method Get
    if ($weatherResponse.success) {
        Write-Host "   [OK] Weather query successful" -ForegroundColor Green
        Write-Host "   City: $($weatherResponse.data.city)" -ForegroundColor Gray
        Write-Host "   Temperature: $($weatherResponse.data.weather.temp)C" -ForegroundColor Gray
        Write-Host "   Weather: $($weatherResponse.data.weather.text)" -ForegroundColor Gray
    } else {
        Write-Host "   [WARN] Query returned error: $($weatherResponse.message)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [FAIL] Weather query failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API service is still running" -ForegroundColor Yellow
Write-Host "Visit the following URLs to test:" -ForegroundColor Gray
Write-Host "  - Health Check: http://localhost:8080/api/health" -ForegroundColor Gray
Write-Host "  - Weather Query: http://localhost:8080/api/weather?city=Beijing" -ForegroundColor Gray
Write-Host "  - Version Info: http://localhost:8080/api/version" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to stop the API service and exit..." -ForegroundColor Cyan

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop API service
Stop-Process -Id $process.Id -Force
Write-Host "API service stopped" -ForegroundColor Green
