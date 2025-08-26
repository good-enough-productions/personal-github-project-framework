@echo off
echo Saving conversation from clipboard...
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0scripts\Save-Conversation.ps1"
pause
