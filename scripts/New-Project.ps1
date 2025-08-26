# GitHub Project Automation - PowerShell Script
# This script automates creating a new GitHub repository and setting it up locally

# =============================================================================
# CONFIGURATION SECTION - CHANGE THESE PATHS TO MATCH YOUR COMPUTER
# =============================================================================

# This is where your projects will be stored on your computer
# IMPORTANT: Change this to your preferred location!
$ProjectsDirectory = "C:\Users\dschm\Documents\GitHub"

# Your GitHub username - IMPORTANT: Change this to your actual GitHub username!
$GitHubUsername = "good-enough-productions"

# =============================================================================
# MAIN SCRIPT - YOU DON'T NEED TO CHANGE ANYTHING BELOW THIS LINE
# =============================================================================

Write-Host "=== GitHub Project Creator ===" -ForegroundColor Cyan
Write-Host "This script will create a new GitHub repository and set it up locally." -ForegroundColor Yellow
Write-Host ""

# Get input from user
$RepoName = Read-Host "Enter the repository name (no spaces, use hyphens instead)"
$Description = Read-Host "Enter a short description of your project"

# Validate input
if ([string]::IsNullOrWhiteSpace($RepoName)) {
    Write-Host "âŒ Repository name cannot be empty. Aborting." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Remove any spaces and replace with hyphens (just in case)
$RepoName = $RepoName -replace ' ', '-'

Write-Host ""
Write-Host "Creating project: $RepoName" -ForegroundColor Green
Write-Host "Description: $Description" -ForegroundColor Green
Write-Host ""

# Check if GitHub CLI is installed and authenticated
Write-Host "Checking GitHub CLI..." -ForegroundColor Cyan
try {
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "âŒ GitHub CLI is not authenticated." -ForegroundColor Red
        Write-Host "Please run 'gh auth login' first and try again." -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit
    }
    Write-Host "âœ… GitHub CLI is ready!" -ForegroundColor Green
}
catch {
    Write-Host "âŒ GitHub CLI is not installed." -ForegroundColor Red
    Write-Host "Please install GitHub CLI first: winget install --id GitHub.cli" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

# Create the projects directory if it doesn't exist
if (!(Test-Path $ProjectsDirectory)) {
    Write-Host "Creating projects directory: $ProjectsDirectory" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ProjectsDirectory -Force | Out-Null
}

# Create GitHub repository
Write-Host "Creating GitHub repository: $RepoName..." -ForegroundColor Cyan
try {
    gh repo create $RepoName --public --description "$Description"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "âŒ Failed to create GitHub repository." -ForegroundColor Red
        Write-Host "This might mean a repository with that name already exists." -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit
    }
    Write-Host "âœ… GitHub repository created!" -ForegroundColor Green
}
catch {
    Write-Host "âŒ Error creating GitHub repository: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Clone the repository locally
Write-Host "Cloning repository to your computer..." -ForegroundColor Cyan
try {
    Set-Location $ProjectsDirectory
    git clone "https://github.com/$GitHubUsername/$RepoName.git"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "âŒ Failed to clone repository." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
    Write-Host "âœ… Repository cloned locally!" -ForegroundColor Green
}
catch {
    Write-Host "âŒ Error cloning repository: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Navigate to the new project directory
$ProjectPath = Join-Path $ProjectsDirectory $RepoName
Set-Location $ProjectPath

# Create a basic README file
Write-Host "Creating initial README file..." -ForegroundColor Cyan
$ReadmeContent = @"
# $RepoName

$Description

## Getting Started

This project was created on $(Get-Date -Format "MMMM dd, yyyy") using automated GitHub project setup.

## Description

$Description

## Next Steps

- [ ] Add your project files
- [ ] Update this README with more details
- [ ] Start coding!

---

*This README was generated automatically. Feel free to customize it for your project.*
"@

$ReadmeContent | Out-File -FilePath "README.md" -Encoding UTF8

# Add, commit, and push the README
Write-Host "Creating initial commit..." -ForegroundColor Cyan
git add README.md
git commit -m "Initial commit with README"
git push -u origin main

# Check if VS Code is available
Write-Host "Opening project in VS Code..." -ForegroundColor Cyan
try {
    code .
    Write-Host "âœ… Project opened in VS Code!" -ForegroundColor Green
}
catch {
    Write-Host "âš ï¸  VS Code not found. You can manually open the folder: $ProjectPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "ðŸŽ‰ All done! Your new project is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Project location: $ProjectPath" -ForegroundColor Cyan
Write-Host "GitHub URL: https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Happy coding! ðŸš€" -ForegroundColor Magenta

# Keep the window open so user can see the results
Read-Host "Press Enter to close this window"

