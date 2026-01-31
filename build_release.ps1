# ============================================================================ #
#            COMPLETE BUILD SCRIPT FOR ENVIROANALYZER PRO                      #
# ============================================================================ #
# This script prepares the project for GitHub release
# ============================================================================ #

Write-Host ""
Write-Host "========================================"
Write-Host "  EnviroAnalyzer Pro - Build Script"
Write-Host "========================================"
Write-Host ""

$projectDir = $PSScriptRoot

# Step 1: Clean up unnecessary files
Write-Host "[1/4] Cleaning up..."
$filesToRemove = @(
    "app_v3.R",
    "main.R", 
    "Rplots.pdf",
    "output"
)

foreach ($file in $filesToRemove) {
    $path = Join-Path $projectDir $file
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        Write-Host "  Removed: $file"
    }
}

# Step 2: Create dist folder for release
Write-Host ""
Write-Host "[2/4] Creating distribution package..."
$distDir = Join-Path $projectDir "dist"
if (Test-Path $distDir) { Remove-Item $distDir -Recurse -Force }
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

# Files to include in release
$releaseFiles = @(
    "app.R",
    "constants.R",
    "functions.R",
    "visuals.R",
    "EnviroAnalyzer.exe",
    "run_app.bat",
    "setup.bat",
    "install_packages.R",
    "README.md",
    "LICENSE"
)

foreach ($file in $releaseFiles) {
    $src = Join-Path $projectDir $file
    $dst = Join-Path $distDir $file
    if (Test-Path $src) {
        Copy-Item $src $dst
        Write-Host "  Copied: $file"
    }
}

# Step 3: Create ZIP file for GitHub release
Write-Host ""
Write-Host "[3/4] Creating ZIP archive..."
$zipPath = Join-Path $projectDir "EnviroAnalyzer_Pro_v3.0.0.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Compress-Archive -Path "$distDir\*" -DestinationPath $zipPath -Force
Write-Host "  Created: EnviroAnalyzer_Pro_v3.0.0.zip"

# Step 4: Summary
Write-Host ""
Write-Host "[4/4] Build Complete!"
Write-Host ""
Write-Host "========================================"
Write-Host "  Release Files Ready"
Write-Host "========================================"
Write-Host ""
Write-Host "ZIP Archive: $zipPath"
Write-Host "Dist Folder: $distDir"
Write-Host ""
Write-Host "To upload to GitHub:"
Write-Host "1. Create a new repository"
Write-Host "2. Push the code"
Write-Host "3. Create a Release"
Write-Host "4. Upload EnviroAnalyzer_Pro_v3.0.0.zip"
Write-Host ""
Write-Host "For MSI Installer (optional):"
Write-Host "1. Install Inno Setup: https://jrsoftware.org/isdl.php"
Write-Host "2. Open installer.iss in Inno Setup"
Write-Host "3. Compile (Ctrl+F9)"
Write-Host ""
