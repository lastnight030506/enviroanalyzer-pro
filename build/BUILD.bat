@echo off
setlocal enabledelayedexpansion

title EnviroAnalyzer Pro - Build Installer
color 0A

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     ENVIROANALYZER PRO - WINDOWS INSTALLER BUILD              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Find R installation
set "R_PATH="
for %%v in (4.5.2 4.5.1 4.5.0 4.4.2 4.4.1 4.4.0 4.3.3 4.3.2) do (
    if exist "C:\Program Files\R\R-%%v\bin\Rscript.exe" (
        set "R_PATH=C:\Program Files\R\R-%%v\bin\Rscript.exe"
        goto :found_r
    )
)

echo [ERROR] R not found!
echo Please install R from: https://cran.r-project.org/
pause
exit /b 1

:found_r
echo [INFO] R found: %R_PATH%
echo.

:: Check for Inno Setup
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    echo [INFO] Inno Setup found
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    echo [INFO] Inno Setup found
) else (
    echo [WARNING] Inno Setup not found!
    echo Please install from: https://jrsoftware.org/isdl.php
    echo.
    choice /C YN /M "Continue anyway"
    if errorlevel 2 exit /b 1
)

echo.
echo Choose build method:
echo   1. RInno (Recommended - simpler, more reliable)
echo   2. electricShine (Electron-based desktop app)
echo.
choice /C 12 /M "Select option"

if errorlevel 2 (
    echo.
    echo Starting electricShine build...
    "%R_PATH%" build\build_electron_installer.R
) else (
    echo.
    echo Starting RInno build...
    "%R_PATH%" build\build_rinno_installer.R
)

echo.
echo ════════════════════════════════════════════════════════════════
echo Build process completed!
echo Check the output directory for the installer.
echo ════════════════════════════════════════════════════════════════
echo.
pause
