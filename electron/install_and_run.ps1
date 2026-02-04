# ============================================================================ #
#           ENVIROANALYZER PRO - ELECTRON LAUNCHER (PowerShell)                #
# ============================================================================ #

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          ENVIROANALYZER PRO - ELECTRON MODE                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Change to electron directory
Set-Location $PSScriptRoot

# Check Node.js
$nodeVersion = $null
try {
    $nodeVersion = node --version 2>$null
} catch {}

if (-not $nodeVersion) {
    Write-Host "❌ Node.js not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Node.js LTS from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Node.js: $nodeVersion" -ForegroundColor Green

# Check npm
$npmVersion = npm --version 2>$null
Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
Write-Host ""

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "[1/2] Installing dependencies..." -ForegroundColor Yellow
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
    Write-Host ""
}

# Start Electron
Write-Host "[2/2] Starting EnviroAnalyzer Pro..." -ForegroundColor Yellow
Write-Host ""

npm start
