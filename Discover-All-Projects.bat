@echo off
echo Discovering and cataloging all your projects...
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0scripts\Discover-Projects.ps1"
pause
