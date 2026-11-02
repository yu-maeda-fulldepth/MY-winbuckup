@echo off
setlocal
cd /d "%~dp0"

echo ======================================================================
echo    Creating Desktop Shortcuts
echo ======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\create_shortcuts.ps1"

echo.
pause

