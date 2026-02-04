@echo off
title EnviroAnalyzer Pro - Electron
cd /d "%~dp0electron"

echo ============================================
echo   EnviroAnalyzer Pro - Electron Mode
echo ============================================
echo.

:: Check if node_modules exists
if not exist "node_modules" (
    echo [1/2] Installing dependencies...
    call npm install
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        echo Make sure Node.js is installed: https://nodejs.org/
        pause
        exit /b 1
    )
    echo.
)

echo [2/2] Starting application...
echo.
call npm start

pause
