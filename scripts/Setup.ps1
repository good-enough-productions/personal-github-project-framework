# GitHub Automation Setup Script
# This script helps you set up the GitHub automation tools for the first time

Write-Host "=== GitHub Automation Setup ===" -ForegroundColor Cyan
Write-Host "This script will help you set up your GitHub automation tools." -ForegroundColor Yellow
Write-Host ""

# Check if running as administrator for some installations
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# Function to check if a command exists
function Test-CommandExists {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check Git installation
Write-Host "1. Checking Git installation..." -ForegroundColor Cyan
if (Test-CommandExists "git") {
    $gitVersion = git --version
    Write-Host "✅ Git is installed: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Git is not installed." -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/" -ForegroundColor Yellow
    Write-Host "Or run this command as Administrator: winget install --id Git.Git" -ForegroundColor Yellow
    $installGit = Read-Host "Would you like me to try installing Git now? (y/n)"
    if ($installGit -eq "y" -or $installGit -eq "Y") {
        if ($isAdmin) {
            winget install --id Git.Git
        } else {
            Write-Host "Administrator privileges required for installation." -ForegroundColor Red
        }
    }
}

Write-Host ""

# Check GitHub CLI installation
Write-Host "2. Checking GitHub CLI installation..." -ForegroundColor Cyan
if (Test-CommandExists "gh") {
    $ghVersion = gh --version | Select-Object -First 1
    Write-Host "✅ GitHub CLI is installed: $ghVersion" -ForegroundColor Green
    
    # Check authentication
    try {
        gh auth status 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $currentUser = gh api user --jq .login
            Write-Host "✅ GitHub CLI is authenticated as: $currentUser" -ForegroundColor Green
        } else {
            Write-Host "⚠️  GitHub CLI is installed but not authenticated." -ForegroundColor Yellow
            $authNow = Read-Host "Would you like to authenticate now? (y/n)"
            if ($authNow -eq "y" -or $authNow -eq "Y") {
                gh auth login
            }
        }
    }
    catch {
        Write-Host "⚠️  Could not check GitHub CLI authentication status." -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ GitHub CLI is not installed." -ForegroundColor Red
    Write-Host "Please install GitHub CLI with: winget install --id GitHub.cli" -ForegroundColor Yellow
    $installGH = Read-Host "Would you like me to try installing GitHub CLI now? (y/n)"
    if ($installGH -eq "y" -or $installGH -eq "Y") {
        if ($isAdmin) {
            winget install --id GitHub.cli
            Write-Host "Please run 'gh auth login' after installation completes." -ForegroundColor Yellow
        } else {
            Write-Host "Administrator privileges required for installation." -ForegroundColor Red
        }
    }
}

Write-Host ""

# Check VS Code installation
Write-Host "3. Checking VS Code installation..." -ForegroundColor Cyan
if (Test-CommandExists "code") {
    Write-Host "✅ VS Code is installed and accessible from command line." -ForegroundColor Green
} else {
    Write-Host "⚠️  VS Code command line tools not found." -ForegroundColor Yellow
    Write-Host "If VS Code is installed, you may need to add it to your PATH." -ForegroundColor Yellow
    Write-Host "Or install VS Code from: https://code.visualstudio.com/" -ForegroundColor Yellow
}

Write-Host ""

# Configure the PowerShell script
Write-Host "4. Configuring your PowerShell script..." -ForegroundColor Cyan

$currentUser = $env:USERNAME
$suggestedPath = "C:\Users\$currentUser\Documents\GitHub"

Write-Host "Current suggested projects directory: $suggestedPath" -ForegroundColor Yellow
$useDefault = Read-Host "Use this path for your projects? (y/n)"

if ($useDefault -eq "n" -or $useDefault -eq "N") {
    $customPath = Read-Host "Enter your preferred projects directory path"
    $suggestedPath = $customPath
}

# Get GitHub username if authenticated
$githubUsername = "YourGitHubUsername"
try {
    if (Test-CommandExists "gh") {
        gh auth status 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $githubUsername = gh api user --jq .login
        }
    }
}
catch {
    # Fallback to manual input
}

if ($githubUsername -eq "YourGitHubUsername") {
    $githubUsername = Read-Host "Enter your GitHub username"
}

# Update the PowerShell script with user's settings
$scriptPath = Join-Path $PSScriptRoot "New-Project.ps1"
if (Test-Path $scriptPath) {
    $scriptContent = Get-Content $scriptPath -Raw
    $scriptContent = $scriptContent -replace 'C:\\Users\\dschm\\Documents\\GitHub', $suggestedPath
    $scriptContent = $scriptContent -replace 'YourGitHubUsername', $githubUsername
    $scriptContent | Set-Content $scriptPath -Encoding UTF8
    Write-Host "✅ PowerShell script configured with your settings!" -ForegroundColor Green
} else {
    Write-Host "⚠️  PowerShell script not found at expected location." -ForegroundColor Yellow
}

# Update the tasks.json file as well
$tasksPath = Join-Path $PSScriptRoot "tasks.json"
if (Test-Path $tasksPath) {
    $tasksContent = Get-Content $tasksPath -Raw
    $tasksContent = $tasksContent -replace 'C:\\\\Users\\\\dschm\\\\Documents\\\\GitHub', $suggestedPath.Replace('\', '\\')
    $tasksContent | Set-Content $tasksPath -Encoding UTF8
    Write-Host "✅ VS Code tasks configured with your settings!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Tasks.json file not found at expected location." -ForegroundColor Yellow
}

Write-Host ""

# Create projects directory
Write-Host "5. Setting up projects directory..." -ForegroundColor Cyan
if (!(Test-Path $suggestedPath)) {
    try {
        New-Item -ItemType Directory -Path $suggestedPath -Force | Out-Null
        Write-Host "✅ Created projects directory: $suggestedPath" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Could not create directory: $suggestedPath" -ForegroundColor Red
        Write-Host "Please create this directory manually." -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ Projects directory already exists: $suggestedPath" -ForegroundColor Green
}

Write-Host ""

# Check PowerShell execution policy
Write-Host "6. Checking PowerShell execution policy..." -ForegroundColor Cyan
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "⚠️  PowerShell execution policy is Restricted." -ForegroundColor Yellow
    Write-Host "You may need to change this to run the automation scripts." -ForegroundColor Yellow
    $changePolicy = Read-Host "Would you like to change it to RemoteSigned? (y/n)"
    if ($changePolicy -eq "y" -or $changePolicy -eq "Y") {
        if ($isAdmin) {
            Set-ExecutionPolicy RemoteSigned -Force
            Write-Host "✅ Execution policy updated!" -ForegroundColor Green
        } else {
            Write-Host "❌ Administrator privileges required to change execution policy." -ForegroundColor Red
            Write-Host "Please run PowerShell as Administrator and run: Set-ExecutionPolicy RemoteSigned" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "✅ PowerShell execution policy is: $executionPolicy" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. You can now run 'New-Project.ps1' to create new GitHub projects" -ForegroundColor White
Write-Host "2. In VS Code, use Ctrl+Shift+P > 'Tasks: Run Task' > 'GitHub: Create New Project'" -ForegroundColor White
Write-Host "3. Your projects will be saved to: $suggestedPath" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Magenta

Read-Host "Press Enter to close this window"
