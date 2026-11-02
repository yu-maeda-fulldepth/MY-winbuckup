@echo off
setlocal
cd /d "%~dp0"

echo ======================================================================
echo    Windows Environment Restore Launcher
echo    (AUV / ROV Field Test Recovery System)
echo ======================================================================
echo.

:: Check for Administrator privileges
openfiles >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo [INFO] Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Ensure logs directory exists
if not exist "logs" mkdir "logs"

echo [INFO] Running restoration script...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\restore.ps1"

echo.
echo ======================================================================
echo    Restoration process completed.
echo    Please restart your PC to ensure all drivers and PATH take effect.
echo ======================================================================
echo.
pause

