@echo off
:: ============================================================================
:: BUILD GUIDE FOR ENVIROANALYZER PRO INSTALLER
:: ============================================================================
:: This guide explains how to create a Windows installer (.exe) for distribution
:: ============================================================================

echo.
echo ========================================
echo   EnviroAnalyzer Pro - Build Guide
echo ========================================
echo.
echo STEP 1: Install Required Tools
echo --------------------------------
echo 1. Download Inno Setup from: https://jrsoftware.org/isdl.php
echo 2. Install Inno Setup (use default settings)
echo.
echo.
echo STEP 2: Create Launcher EXE
echo --------------------------------
echo Option A: Use VBS directly (no EXE needed)
echo   - The EnviroAnalyzer.vbs file can launch the app
echo.
echo Option B: Convert VBS to EXE
echo   - Download vbs2exe or similar tool
echo   - Or use PowerShell to create a wrapper
echo.
echo.
echo STEP 3: Build Installer
echo --------------------------------
echo 1. Open Inno Setup Compiler
echo 2. Open 'installer.iss' file
echo 3. Click 'Compile' (Ctrl+F9)
echo 4. The installer will be created in 'installer/' folder
echo.
echo.
echo STEP 4: Upload to GitHub
echo --------------------------------
echo 1. Create a new release on GitHub
echo 2. Upload 'installer/EnviroAnalyzer_Pro_Setup.exe'
echo 3. Users can download and install
echo.
echo ========================================
echo.
pause
