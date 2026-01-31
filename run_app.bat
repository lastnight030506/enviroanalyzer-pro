@echo off
title EnviroAnalyzer Pro - Starting...
color 0A

echo ========================================
echo    EnviroAnalyzer Pro v3.0
echo    Environmental Quality Assessment
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
    echo [ERROR] R is not installed or not found!
    echo Please install R from: https://cran.r-project.org/bin/windows/base/
    pause
    exit /b 1
)

echo [OK] Found R at: %R_PATH%
echo.

:: Change to app directory
cd /d "%~dp0"
echo [OK] Working directory: %cd%
echo.

:: Kill any existing R processes using port 3838
echo [INFO] Checking for existing instances...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3838 ^| findstr LISTENING 2^>nul') do (
    echo [INFO] Stopping existing process on port 3838...
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo [INFO] Starting EnviroAnalyzer Pro...
echo [INFO] Opening browser at http://127.0.0.1:3838
echo.
echo ========================================
echo    Press Ctrl+C to stop the server
echo ========================================
echo.

:: Start the app
"%R_PATH%" -e "shiny::runApp('app.R', port = 3838, host = '127.0.0.1', launch.browser = TRUE)"

echo.
echo [INFO] Server stopped.
pause
