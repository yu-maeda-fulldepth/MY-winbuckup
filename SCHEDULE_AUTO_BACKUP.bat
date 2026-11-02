@echo off
setlocal
cd /d "%~dp0"

echo ======================================================================
echo    Windows Environment Auto-Backup Schedule Setup
echo    (Register to Windows Task Scheduler)
echo ======================================================================
echo.

:: Check for Administrator privileges
openfiles >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo [INFO] Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\schedule_task.ps1"

echo.
pause
