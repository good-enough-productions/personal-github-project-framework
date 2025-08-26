@echo off
echo Finding project synergies and integration opportunities...
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0scripts\Find-Synergies.ps1" -ShowIntegrationIdeas
pause
