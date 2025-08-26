# Helper Functions for {{PROJECT_NAME}}
# Common utilities and reusable functions

function Test-Administrator {
    <#
    .SYNOPSIS
    Checks if the current PowerShell session is running as Administrator
    
    .EXAMPLE
    if (Test-Administrator) { Write-Host "Running as Admin" }
    #>
    
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-Progress {
    <#
    .SYNOPSIS
    Displays a progress bar with percentage
    
    .PARAMETER Activity
    Description of the current activity
    
    .PARAMETER Status
    Current status message
    
    .PARAMETER PercentComplete
    Percentage complete (0-100)
    
    .EXAMPLE
    Show-Progress -Activity "Processing Files" -Status "File 5 of 10" -PercentComplete 50
    #>
    
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )
    
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

function Invoke-WithRetry {
    <#
    .SYNOPSIS
    Executes a script block with retry logic
    
    .PARAMETER ScriptBlock
    The script block to execute
    
    .PARAMETER MaxAttempts
    Maximum number of retry attempts (default: 3)
    
    .PARAMETER DelaySeconds
    Delay between attempts in seconds (default: 2)
    
    .EXAMPLE
    Invoke-WithRetry -ScriptBlock { Test-Connection "google.com" } -MaxAttempts 5
    #>
    
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 2
    )
    
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            return & $ScriptBlock
        }
        catch {
            if ($attempt -eq $MaxAttempts) {
                throw "Failed after $MaxAttempts attempts: $_"
            }
            
            Write-Warning "Attempt $attempt failed: $_. Retrying in $DelaySeconds seconds..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Get-FileSize {
    <#
    .SYNOPSIS
    Gets human-readable file size
    
    .PARAMETER FilePath
    Path to the file
    
    .EXAMPLE
    Get-FileSize "C:\file.txt"  # Returns "1.5 MB"
    #>
    
    param([string]$FilePath)
    
    if (!(Test-Path $FilePath)) {
        return "File not found"
    }
    
    $size = (Get-Item $FilePath).Length
    
    if ($size -lt 1KB) { return "$size bytes" }
    elseif ($size -lt 1MB) { return "{0:N2} KB" -f ($size / 1KB) }
    elseif ($size -lt 1GB) { return "{0:N2} MB" -f ($size / 1MB) }
    else { return "{0:N2} GB" -f ($size / 1GB) }
}

function Send-Notification {
    <#
    .SYNOPSIS
    Shows a Windows notification toast
    
    .PARAMETER Title
    Notification title
    
    .PARAMETER Message
    Notification message
    
    .EXAMPLE
    Send-Notification -Title "Process Complete" -Message "Your automation finished successfully"
    #>
    
    param(
        [string]$Title,
        [string]$Message
    )
    
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $notification = New-Object System.Windows.Forms.NotifyIcon
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.BalloonTipTitle = $Title
        $notification.BalloonTipText = $Message
        $notification.Visible = $true
        $notification.ShowBalloonTip(5000)
        
        # Clean up
        Start-Sleep -Seconds 1
        $notification.Dispose()
    }
    catch {
        Write-Warning "Could not show notification: $_"
    }
}

function Test-InternetConnection {
    <#
    .SYNOPSIS
    Tests internet connectivity
    
    .EXAMPLE
    if (Test-InternetConnection) { Write-Host "Internet is available" }
    #>
    
    try {
        $ping = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
        return $ping
    }
    catch {
        return $false
    }
}
