@echo off
echo Starting {{PROJECT_NAME}}...
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0main.ps1"
pause
