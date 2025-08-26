# Quick Start Guide for GitHub Automation System
# Run this script to get started with the automation tools

Write-Host "=== GitHub Automation System - Quick Start ===" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check PowerShell version
$PSVersion = $PSVersionTable.PSVersion
Write-Host "✓ PowerShell version: $PSVersion" -ForegroundColor Green

# Check Git
try {
    $GitVersion = git --version
    Write-Host "✓ Git: $GitVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Git not found. Please install Git first." -ForegroundColor Red
    Write-Host "   Download from: https://git-scm.com/" -ForegroundColor Yellow
    return
}

# Check GitHub CLI
try {
    $GHVersion = gh --version | Select-Object -First 1
    Write-Host "✓ GitHub CLI: $GHVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ GitHub CLI not found. Please install GitHub CLI first." -ForegroundColor Red
    Write-Host "   Download from: https://cli.github.com/" -ForegroundColor Yellow
    return
}

# Check authentication
Write-Host ""
Write-Host "Checking GitHub authentication..." -ForegroundColor Yellow
try {
    $AuthStatus = gh auth status 2>&1
    if ($AuthStatus -match "Logged in") {
        Write-Host "✓ GitHub CLI authenticated" -ForegroundColor Green
    }
    else {
        throw "Not authenticated"
    }
}
catch {
    Write-Host "⚠️ GitHub CLI not authenticated" -ForegroundColor Yellow
    Write-Host "Run: gh auth login" -ForegroundColor Cyan
    
    $Authenticate = Read-Host "Would you like to authenticate now? (y/n)"
    if ($Authenticate -eq 'y' -or $Authenticate -eq 'Y') {
        gh auth login
    }
}

Write-Host ""
Write-Host "=== Available Tools ===" -ForegroundColor Cyan
Write-Host ""

# List available scripts
$ScriptPath = Join-Path $PSScriptRoot "scripts"
$Scripts = @(
    @{Name="Enhanced-Project-Creator.ps1"; Description="Create new projects or clone existing ones"},
    @{Name="Template-Manager.ps1"; Description="Manage code project templates"},
    @{Name="Context-Manager.ps1"; Description="Manage AI context templates"},
    @{Name="Project-Discovery.ps1"; Description="Scan and catalog existing projects"}
)

foreach ($Script in $Scripts) {
    $ScriptFile = Join-Path $ScriptPath $Script.Name
    if (Test-Path $ScriptFile) {
        Write-Host "✓ $($Script.Name)" -ForegroundColor Green
        Write-Host "   $($Script.Description)" -ForegroundColor White
    }
    else {
        Write-Host "❌ $($Script.Name) - Not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Quick Actions ===" -ForegroundColor Cyan
Write-Host ""

$Action = Read-Host @"
Choose an action:
1) Create a new project
2) Clone an existing repository  
3) Manage code templates
4) Set up AI context templates
5) Discover existing projects
6) View full documentation

Enter choice (1-6)
"@

switch ($Action) {
    "1" {
        Write-Host ""
        Write-Host "Starting Enhanced Project Creator..." -ForegroundColor Green
        & "$ScriptPath\Enhanced-Project-Creator.ps1"
    }
    "2" {
        Write-Host ""
        $CloneUrl = Read-Host "Enter GitHub repository URL to clone"
        if ($CloneUrl) {
            & "$ScriptPath\Enhanced-Project-Creator.ps1" -CloneUrl $CloneUrl
        }
    }
    "3" {
        Write-Host ""
        Write-Host "Opening Template Manager..." -ForegroundColor Green
        & "$ScriptPath\Template-Manager.ps1"
    }
    "4" {
        Write-Host ""
        Write-Host "Opening Context Template Manager..." -ForegroundColor Green
        Write-Host "This will help you set up AI context for better collaboration" -ForegroundColor Yellow
        & "$ScriptPath\Context-Manager.ps1" -Action update
    }
    "5" {
        Write-Host ""
        Write-Host "Discovering existing projects..." -ForegroundColor Green
        & "$ScriptPath\Project-Discovery.ps1"
    }
    "6" {
        Write-Host ""
        Write-Host "Opening documentation..." -ForegroundColor Green
        try {
            $ReadmePath = Join-Path (Split-Path $PSScriptRoot -Parent) "README.md"
            code $ReadmePath
        }
        catch {
            Write-Host "Could not open VS Code. README location:" -ForegroundColor Yellow
            Write-Host $ReadmePath -ForegroundColor White
        }
    }
    default {
        Write-Host "Invalid choice. Run the script again to try." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Helpful Tips ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 For daily use:" -ForegroundColor Yellow
Write-Host "   - Use VS Code tasks (Ctrl+Shift+P → 'Tasks: Run Task')" -ForegroundColor White
Write-Host "   - Create AI context templates for better LLM collaboration" -ForegroundColor White
Write-Host "   - Run scripts directly with parameters for automation" -ForegroundColor White
Write-Host ""
Write-Host "📚 Need help?" -ForegroundColor Yellow
Write-Host "   - Check README.md for comprehensive documentation" -ForegroundColor White
Write-Host "   - Run any script with -Help parameter for usage info" -ForegroundColor White
Write-Host "   - Use Context-Manager.ps1 to set up AI assistance" -ForegroundColor White
