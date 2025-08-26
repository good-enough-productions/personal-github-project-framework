# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Quick Start

1. **Right-click `main.ps1`** and select "Run with PowerShell"
2. **Or from PowerShell:** `.\main.ps1`

## Features

- ✅ Proper error handling and logging
- ✅ Parameter validation
- ✅ Progress indicators
- ✅ Colored output for better readability
- ✅ Help documentation

## Usage

```powershell
# Basic usage
.\main.ps1

# With parameters (customize in main.ps1)
.\main.ps1 -Parameter1 "value" -Parameter2 "value"

# Get help
Get-Help .\main.ps1 -Full
```

## Project Structure

```
{{PROJECT_NAME}}/
├── main.ps1            # Main automation script
├── modules/            # Helper functions and modules
│   └── helpers.ps1     # Common helper functions
├── config/             # Configuration files
│   └── settings.json   # Script settings
├── logs/               # Log files (auto-created)
├── README.md           # This file
└── run.bat             # Double-click runner
```

## Configuration

Edit `config/settings.json` to customize script behavior.

## Troubleshooting

### "Execution Policy" Error
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Need Administrator Rights
Right-click PowerShell and "Run as Administrator"

## Notes

Created on {{DATE}} using Enhanced GitHub Project Creator.

---

*This project was generated from the PowerShell Automation template.*
