@echo off
setlocal
cd /d "%~dp0"

echo ======================================================================
echo    Windows Environment Backup and GitHub Push Launcher
echo    (AUV / ROV Field Test Backup System)
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

echo [INFO] Running backup and GitHub push script...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\backup_and_push.ps1"

echo.
echo ======================================================================
echo    Process finished!
echo ======================================================================
echo.
pause
