# ============================================================================
#   LOCAL BUILD SCRIPT - Create Both Installer Versions
# ============================================================================
# Run this script locally to build both Lightweight and Standalone installers
# Requirements:
#   - R 4.x installed
#   - Inno Setup 6 installed
#   - Internet connection (to download R Portable)
# ============================================================================

param(
    [string]$Version = "3.0.0",
    [switch]$LightweightOnly,
    [switch]$StandaloneOnly,
    [switch]$SkipRDownload
)

$ErrorActionPreference = "Stop"

# ---- Configuration ----
$RVersion = "4.4.2"
$RDownloadUrl = "https://cloud.r-project.org/bin/windows/base/old/$RVersion/R-$RVersion-win.exe"
$ProjectDir = $PSScriptRoot
if (-not $ProjectDir) { $ProjectDir = Get-Location }

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     ENVIROANALYZER PRO - LOCAL BUILD                              ║" -ForegroundColor Cyan
Write-Host "║     Version: $Version                                                  ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ---- Find Tools ----
Write-Host "[1/7] Finding required tools..." -ForegroundColor Yellow

# Find R
$RScript = $null
foreach ($v in @("4.5.2", "4.5.1", "4.5.0", "4.4.2", "4.4.1", "4.4.0", "4.3.3", "4.3.2")) {
    $path = "C:\Program Files\R\R-$v\bin\Rscript.exe"
    if (Test-Path $path) {
        $RScript = $path
        Write-Host "    ✓ R found: R-$v" -ForegroundColor Green
        break
    }
}
if (-not $RScript) {
    Write-Error "R not found! Install from: https://cran.r-project.org/"
    exit 1
}

# Find Inno Setup
$InnoSetup = $null
$innoPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
)
foreach ($path in $innoPaths) {
    if (Test-Path $path) {
        $InnoSetup = $path
        Write-Host "    ✓ Inno Setup found" -ForegroundColor Green
        break
    }
}
if (-not $InnoSetup) {
    Write-Error "Inno Setup not found! Install from: https://jrsoftware.org/isdl.php"
    exit 1
}

# ---- Create Directories ----
Write-Host ""
Write-Host "[2/7] Creating build directories..." -ForegroundColor Yellow

$BuildDir = Join-Path $ProjectDir "build_output"
$LightweightDir = Join-Path $BuildDir "lightweight"
$StandaloneDir = Join-Path $BuildDir "standalone"
$RPortableDir = Join-Path $StandaloneDir "R-Portable"

Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $LightweightDir -Force | Out-Null
New-Item -ItemType Directory -Path $StandaloneDir -Force | Out-Null
Write-Host "    ✓ Created build directories" -ForegroundColor Green

# ---- Copy App Files ----
Write-Host ""
Write-Host "[3/7] Copying application files..." -ForegroundColor Yellow

$appFiles = @("app.R", "constants.R", "functions.R", "visuals.R", "run.R", "LICENSE")
foreach ($file in $appFiles) {
    $src = Join-Path $ProjectDir $file
    if (Test-Path $src) {
        Copy-Item $src $LightweightDir
        Copy-Item $src $StandaloneDir
        Write-Host "    ✓ $file" -ForegroundColor Green
    }
}

# ---- Create Launchers ----
Write-Host ""
Write-Host "[4/7] Creating launcher scripts..." -ForegroundColor Yellow

# Lightweight launcher
$lightweightLauncher = @'
@echo off
setlocal enabledelayedexpansion
title EnviroAnalyzer Pro

set "R_PATH="
for %%v in (4.5.2 4.5.1 4.5.0 4.4.2 4.4.1 4.4.0 4.3.3 4.3.2) do (
    if exist "C:\Program Files\R\R-%%v\bin\Rscript.exe" (
        set "R_PATH=C:\Program Files\R\R-%%v\bin\Rscript.exe"
        goto :found
    )
)

echo R is not installed!
echo Download from: https://cran.r-project.org/bin/windows/base/
start "" "https://cran.r-project.org/bin/windows/base/"
pause
exit /b 1

:found
cd /d "%~dp0"
"%R_PATH%" run.R
'@
$lightweightLauncher | Out-File -FilePath (Join-Path $LightweightDir "EnviroAnalyzer.bat") -Encoding ASCII

# Standalone launcher
$standaloneLauncher = @"
@echo off
title EnviroAnalyzer Pro
cd /d "%~dp0"
set "R_PATH=%~dp0R-Portable\R-$RVersion\bin\Rscript.exe"
"%R_PATH%" run.R
"@
$standaloneLauncher | Out-File -FilePath (Join-Path $StandaloneDir "EnviroAnalyzer.bat") -Encoding ASCII

Write-Host "    ✓ Created launcher scripts" -ForegroundColor Green

# ---- Download R Portable (for Standalone) ----
if (-not $LightweightOnly -and -not $SkipRDownload) {
    Write-Host ""
    Write-Host "[5/7] Downloading R Portable..." -ForegroundColor Yellow
    Write-Host "    ⏳ This may take a few minutes..." -ForegroundColor Gray
    
    $rInstaller = Join-Path $BuildDir "R-$RVersion-win.exe"
    
    if (-not (Test-Path $rInstaller)) {
        Invoke-WebRequest -Uri $RDownloadUrl -OutFile $rInstaller -UseBasicParsing
    }
    Write-Host "    ✓ Downloaded R installer" -ForegroundColor Green
    
    Write-Host "    ⏳ Extracting R (this takes a while)..." -ForegroundColor Gray
    Start-Process -FilePath $rInstaller -ArgumentList "/VERYSILENT", "/DIR=$RPortableDir\R-$RVersion" -Wait
    Write-Host "    ✓ Extracted R Portable" -ForegroundColor Green
    
    # Install packages
    Write-Host ""
    Write-Host "[6/7] Installing R packages..." -ForegroundColor Yellow
    Write-Host "    ⏳ This may take 10-15 minutes..." -ForegroundColor Gray
    
    $rscriptPortable = Join-Path $RPortableDir "R-$RVersion\bin\Rscript.exe"
    $installScript = @"
options(repos = c(CRAN = 'https://cloud.r-project.org'))
pkgs <- c('shiny', 'shinyjs', 'bslib', 'thematic', 'tidyverse', 
          'gt', 'DT', 'shinyWidgets', 'rhandsontable', 'writexl', 
          'scales', 'readxl')
install.packages(pkgs, Ncpus = 4, quiet = TRUE)
cat('Installed:', length(pkgs), 'packages\n')
"@
    & $rscriptPortable -e $installScript
    Write-Host "    ✓ Packages installed" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[5/7] Skipping R Portable download" -ForegroundColor Gray
    Write-Host "[6/7] Skipping package installation" -ForegroundColor Gray
}

# ---- Build Installers ----
Write-Host ""
Write-Host "[7/7] Building installers..." -ForegroundColor Yellow

# Update version in ISS files
$issLightweight = Join-Path $ProjectDir "installer\lightweight.iss"
$issStandalone = Join-Path $ProjectDir "installer\standalone.iss"

if (Test-Path $issLightweight) {
    (Get-Content $issLightweight) -replace 'MyAppVersion ".*"', "MyAppVersion `"$Version`"" | Set-Content $issLightweight
}
if (Test-Path $issStandalone) {
    (Get-Content $issStandalone) -replace 'MyAppVersion ".*"', "MyAppVersion `"$Version`"" | Set-Content $issStandalone
}

# Build Lightweight
if (-not $StandaloneOnly) {
    Write-Host "    Building Lightweight..." -ForegroundColor Gray
    & $InnoSetup $issLightweight 2>&1 | Out-Null
    $lightweightExe = Get-ChildItem "$LightweightDir\*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($lightweightExe) {
        $size = [math]::Round($lightweightExe.Length / 1MB, 2)
        Write-Host "    ✓ Lightweight: $($lightweightExe.Name) ($size MB)" -ForegroundColor Green
    }
}

# Build Standalone
if (-not $LightweightOnly -and (Test-Path $RPortableDir)) {
    Write-Host "    Building Standalone..." -ForegroundColor Gray
    & $InnoSetup $issStandalone 2>&1 | Out-Null
    $standaloneExe = Get-ChildItem "$StandaloneDir\*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($standaloneExe) {
        $size = [math]::Round($standaloneExe.Length / 1MB, 2)
        Write-Host "    ✓ Standalone: $($standaloneExe.Name) ($size MB)" -ForegroundColor Green
    }
}

# ---- Summary ----
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     ✓ BUILD COMPLETE                                              ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Output directory: $BuildDir" -ForegroundColor Cyan
Write-Host ""

Get-ChildItem "$BuildDir\*\*.exe" -ErrorAction SilentlyContinue | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "📦 $($_.FullName)" -ForegroundColor White
    Write-Host "   Size: $size MB" -ForegroundColor Gray
}

Write-Host ""
explorer.exe $BuildDir
