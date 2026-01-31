@echo off
title EnviroAnalyzer Pro - Installing Dependencies
color 0E

echo ========================================
echo    EnviroAnalyzer Pro - Setup
echo    Installing Required Packages
echo ========================================
echo.

:: Check if R is installed
set "R_PATH=C:\Program Files\R\R-4.5.2\bin\Rscript.exe"
if not exist "%R_PATH%" (
    set "R_PATH=C:\Program Files\R\R-4.4.0\bin\Rscript.exe"
)
if not exist "%R_PATH%" (
    for /f "tokens=*" %%i in ('where Rscript 2^>nul') do set "R_PATH=%%i"
)
if not exist "%R_PATH%" (
    echo [ERROR] R is not installed!
    echo.
    echo Please download and install R from:
    echo https://cran.r-project.org/bin/windows/base/
    echo.
    pause
    exit /b 1
)

echo [OK] Found R at: %R_PATH%
echo.

cd /d "%~dp0"

echo [INFO] Installing packages... This may take a few minutes.
echo.

"%R_PATH%" install_packages.R

echo.
echo ========================================
echo    Setup Complete!
echo    Double-click 'run_app.bat' to start
echo ========================================
echo.
pause
