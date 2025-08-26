# {{PROJECT_NAME}} - {{PROJECT_DESCRIPTION}}
# Created on {{DATE}}

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, HelpMessage="Example parameter - customize as needed")]
    [string]$InputPath,
    
    [Parameter(Mandatory=$false, HelpMessage="Enable verbose logging")]
    [switch]$Verbose,
    
    [Parameter(Mandatory=$false, HelpMessage="Run in test mode without making changes")]
    [switch]$WhatIf
)

# Load configuration and helpers
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigPath = Join-Path $ScriptPath "config\settings.json"
$HelpersPath = Join-Path $ScriptPath "modules\helpers.ps1"

# Import helper functions
if (Test-Path $HelpersPath) {
    . $HelpersPath
} else {
    Write-Warning "Helper functions not found at $HelpersPath"
}

# Load configuration
$Config = @{}
if (Test-Path $ConfigPath) {
    try {
        $Config = Get-Content $ConfigPath | ConvertFrom-Json -AsHashtable
        Write-Host "✅ Configuration loaded" -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not load configuration: $_"
    }
} else {
    Write-Warning "Configuration file not found at $ConfigPath"
}

# Initialize logging
$LogDir = Join-Path $ScriptPath "logs"
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}
$LogFile = Join-Path $LogDir "$(Get-Date -Format 'yyyy-MM-dd')-{{PROJECT_NAME}}.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    # Write to console with colors
    switch ($Level) {
        "ERROR" { Write-Host $LogEntry -ForegroundColor Red }
        "WARN"  { Write-Host $LogEntry -ForegroundColor Yellow }
        "INFO"  { Write-Host $LogEntry -ForegroundColor Cyan }
        default { Write-Host $LogEntry }
    }
    
    # Write to log file
    $LogEntry | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Main script logic starts here
try {
    Write-Log "Starting {{PROJECT_NAME}}"
    Write-Log "{{PROJECT_DESCRIPTION}}"
    
    if ($WhatIf) {
        Write-Log "Running in WhatIf mode - no changes will be made" "WARN"
    }
    
    # TODO: Add your main automation logic here
    Write-Log "Main automation logic goes here"
    
    # Example: Process input if provided
    if ($InputPath) {
        Write-Log "Processing input path: $InputPath"
        
        if (Test-Path $InputPath) {
            Write-Log "Input path exists, processing..."
            # Add your processing logic here
        } else {
            Write-Log "Input path does not exist: $InputPath" "ERROR"
            exit 1
        }
    }
    
    # Example: Use configuration
    if ($Config.Count -gt 0) {
        Write-Log "Using configuration settings:"
        $Config.GetEnumerator() | ForEach-Object {
            Write-Log "  $($_.Key): $($_.Value)"
        }
    }
    
    Write-Log "{{PROJECT_NAME}} completed successfully!"
    
} catch {
    Write-Log "Error occurred: $_" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

# Keep window open if run by double-clicking
if ($Host.Name -eq "ConsoleHost") {
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
