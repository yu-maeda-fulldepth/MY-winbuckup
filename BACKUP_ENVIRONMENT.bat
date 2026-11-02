@echo off
setlocal
cd /d "%~dp0"

echo ======================================================================
echo    Windows Environment Backup Launcher
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

echo [INFO] Running backup script...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\backup.ps1"

echo.
echo ======================================================================
echo    Backup process completed successfully!
echo    Please copy this winbackup folder to your portable SSD / USB drive.
echo ======================================================================
echo.
pause

