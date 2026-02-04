@echo off
setlocal enabledelayedexpansion
title EnviroAnalyzer Pro

:: Find R installation
set "R_PATH="
for %%v in (4.5.2 4.5.1 4.5.0 4.4.2 4.4.1 4.4.0 4.3.3 4.3.2 4.3.1 4.3.0) do (
    if exist "C:\Program Files\R\R-%%v\bin\Rscript.exe" (
        set "R_PATH=C:\Program Files\R\R-%%v\bin\Rscript.exe"
        goto :found
    )
)

:: R not found - show message
echo ============================================
echo   R is required but not installed!
echo ============================================
echo.
echo Please download and install R from:
echo   https://cran.r-project.org/bin/windows/base/
echo.
echo After installing R, run this app again.
echo.
start "" "https://cran.r-project.org/bin/windows/base/"
pause
exit /b 1

:found
echo ============================================
echo   EnviroAnalyzer Pro v3.0
echo   Starting application...
echo ============================================
echo.
echo R Path: %R_PATH%
echo.

cd /d "%~dp0"
"%R_PATH%" run.R
