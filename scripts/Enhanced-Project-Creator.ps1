# Enhanced GitHub Project Creator
# This script creates new projects OR clones existing ones with template support

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$CloneUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$Template,
    
    [Parameter(Mandatory=$false)]
    [string]$Description,
    
    [Parameter(Mandatory=$false)]
    [switch]$Private,
    
    [Parameter(Mandatory=$false)]
    [string]$LocalPath
)

# =============================================================================
# CONFIGURATION SECTION - CHANGE THESE PATHS TO MATCH YOUR COMPUTER
# =============================================================================

# This is where your projects will be stored on your computer
# IMPORTANT: Change this to your preferred location!
$ProjectsDirectory = "C:\Users\dschm\Documents\GitHub"

# Your GitHub username - IMPORTANT: Change this to your actual GitHub username!
$GitHubUsername = "good-enough-productions"

# Templates directory
$TemplatesDirectory = Join-Path (Split-Path $PSScriptRoot -Parent) "templates"

# =============================================================================
# MAIN SCRIPT - YOU DON'T NEED TO CHANGE ANYTHING BELOW THIS LINE
# =============================================================================

Write-Host "=== Enhanced GitHub Project Creator ===" -ForegroundColor Cyan
Write-Host "Create new repositories or clone existing ones with intelligent templates." -ForegroundColor Yellow
Write-Host ""

# Function to show available templates
function Show-Templates {
    Write-Host "Available Templates:" -ForegroundColor Cyan
    if (Test-Path $TemplatesDirectory) {
        $Templates = Get-ChildItem $TemplatesDirectory -Directory
        if ($Templates) {
            for ($i = 0; $i -lt $Templates.Count; $i++) {
                $Template = $Templates[$i]
                $DescFile = Join-Path $Template.FullName "template.json"
                $Description = "Basic template"
                
                if (Test-Path $DescFile) {
                    try {
                        $TemplateInfo = Get-Content $DescFile | ConvertFrom-Json
                        $Description = $TemplateInfo.description
                    }
                    catch { }
                }
                
                Write-Host "  $($i + 1). $($Template.Name) - $Description" -ForegroundColor White
            }
            Write-Host "  0. No template (empty project)" -ForegroundColor White
            return $Templates
        }
    }
    Write-Host "  0. No template (empty project)" -ForegroundColor White
    return @()
}

# Get project mode
if ($CloneUrl) {
    $Mode = "2"  # Auto-select clone mode if URL provided
} elseif ($ProjectName -and !$CloneUrl) {
    $Mode = "1"  # Auto-select create mode if project name provided
} else {
    Write-Host "Project Mode:" -ForegroundColor Cyan
    Write-Host "  1. Create new repository" -ForegroundColor White
    Write-Host "  2. Clone existing repository" -ForegroundColor White
    $Mode = Read-Host "Choose mode (1 or 2)"
}

if ($Mode -eq "2") {
    # Clone existing repository mode
    Write-Host ""
    Write-Host "=== Clone Existing Repository ===" -ForegroundColor Green
    
    if (-not $CloneUrl) {
        $RepoUrl = Read-Host "Enter the repository URL (e.g., https://github.com/user/repo.git)"
    } else {
        $RepoUrl = $CloneUrl
    }
    
    if (-not $ProjectName) {
        $ProjectName = Read-Host "Enter your preferred project name (or press Enter to use repo name)"
    }
    
    if (-not $Description) {
        $Notes = Read-Host "Enter notes about this project (optional)"
    } else {
        $Notes = $Description
    }
    
    # Validate URL
    if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
        Write-Host "❌ Repository URL cannot be empty. Aborting." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
    
    # Extract repo name from URL if no custom name provided
    if ([string]::IsNullOrWhiteSpace($ProjectName)) {
        $ProjectName = Split-Path $RepoUrl -Leaf
        $ProjectName = $ProjectName -replace '\.git$', ''
    }
    
    # Remove any spaces and replace with hyphens
    $ProjectName = $ProjectName -replace ' ', '-'
    
    Write-Host ""
    Write-Host "Cloning: $RepoUrl" -ForegroundColor Green
    Write-Host "As: $ProjectName" -ForegroundColor Green
    if ($Notes) { Write-Host "Notes: $Notes" -ForegroundColor Green }
    
    # Create the projects directory if it doesn't exist
    if (!(Test-Path $ProjectsDirectory)) {
        Write-Host "Creating projects directory: $ProjectsDirectory" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $ProjectsDirectory -Force | Out-Null
    }
    
    # Clone the repository
    Write-Host ""
    Write-Host "Cloning repository..." -ForegroundColor Cyan
    try {
        Set-Location $ProjectsDirectory
        
        # Compare project name with default repo name
        $DefaultRepoName = Split-Path $RepoUrl -Leaf
        $DefaultRepoName = $DefaultRepoName -replace '\.git$', ''
        
        if ($ProjectName -ne $DefaultRepoName) {
            # Custom name - clone into specific directory
            git clone $RepoUrl $ProjectName
        } else {
            # Use default name
            git clone $RepoUrl
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to clone repository." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit
        }
        Write-Host "✅ Repository cloned successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error cloning repository: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
    
    # Navigate to the project directory
    $ProjectPath = Join-Path $ProjectsDirectory $ProjectName
    Set-Location $ProjectPath
    
    # Add notes to a local file if provided
    if ($Notes) {
        Write-Host "Adding project notes..." -ForegroundColor Cyan
        $NotesContent = @"
# Project Notes

**Cloned from:** $RepoUrl  
**Date:** $(Get-Date -Format "MMMM dd, yyyy 'at' h:mm tt")  
**Notes:** $Notes  

---

*This project was cloned using the Enhanced GitHub Project Creator*
"@
        $NotesContent | Out-File -FilePath "PROJECT-NOTES.md" -Encoding UTF8
    }
    
} else {
    # Create new repository mode (original functionality with templates)
    Write-Host ""
    Write-Host "=== Create New Repository ===" -ForegroundColor Green
    
    # Show available templates
    Write-Host ""
    $AvailableTemplates = Show-Templates
    
    $TemplateChoice = 0
    if ($AvailableTemplates.Count -gt 0) {
        $TemplateChoice = Read-Host "Choose template (0-$($AvailableTemplates.Count))"
        try {
            $TemplateChoice = [int]$TemplateChoice
            if ($TemplateChoice -lt 0 -or $TemplateChoice -gt $AvailableTemplates.Count) {
                $TemplateChoice = 0
            }
        }
        catch {
            $TemplateChoice = 0
        }
    }
    
    Write-Host ""
    $RepoName = Read-Host "Enter the repository name (no spaces, use hyphens instead)"
    $Notes = Read-Host "Enter project description/notes"
    
    # Validate input
    if ([string]::IsNullOrWhiteSpace($RepoName)) {
        Write-Host "❌ Repository name cannot be empty. Aborting." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
    
    # Remove any spaces and replace with hyphens (just in case)
    $RepoName = $RepoName -replace ' ', '-'
    
    $SelectedTemplate = $null
    if ($TemplateChoice -gt 0 -and $TemplateChoice -le $AvailableTemplates.Count) {
        $SelectedTemplate = $AvailableTemplates[$TemplateChoice - 1]
        Write-Host ""
        Write-Host "Using template: $($SelectedTemplate.Name)" -ForegroundColor Magenta
    }
    
    Write-Host ""
    Write-Host "Creating project: $RepoName" -ForegroundColor Green
    Write-Host "Notes: $Notes" -ForegroundColor Green
    Write-Host ""
    
    # Check if GitHub CLI is installed and authenticated
    Write-Host "Checking GitHub CLI..." -ForegroundColor Cyan
    try {
        gh auth status 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ GitHub CLI is not authenticated." -ForegroundColor Red
            Write-Host "Please run 'gh auth login' first and try again." -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit
        }
        Write-Host "✅ GitHub CLI is ready!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ GitHub CLI is not installed." -ForegroundColor Red
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
        gh repo create $RepoName --public --description "$Notes"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to create GitHub repository." -ForegroundColor Red
            Write-Host "This might mean a repository with that name already exists." -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit
        }
        Write-Host "✅ GitHub repository created!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error creating GitHub repository: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
    
    # Clone the repository locally
    Write-Host "Cloning repository to your computer..." -ForegroundColor Cyan
    try {
        Set-Location $ProjectsDirectory
        git clone "https://github.com/$GitHubUsername/$RepoName.git"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to clone repository." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit
        }
        Write-Host "✅ Repository cloned locally!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error cloning repository: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
    
    # Navigate to the new project directory
    $ProjectPath = Join-Path $ProjectsDirectory $RepoName
    Set-Location $ProjectPath
    
    # Apply template if selected
    if ($SelectedTemplate) {
        Write-Host "Applying template: $($SelectedTemplate.Name)..." -ForegroundColor Cyan
        try {
            # Copy template files
            $TemplateFiles = Get-ChildItem $SelectedTemplate.FullName -Recurse -File | Where-Object { $_.Name -ne "template.json" }
            foreach ($File in $TemplateFiles) {
                $RelativePath = $File.FullName.Replace($SelectedTemplate.FullName, "").TrimStart('\')
                $DestPath = Join-Path $ProjectPath $RelativePath
                $DestDir = Split-Path $DestPath -Parent
                
                if (!(Test-Path $DestDir)) {
                    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
                }
                
                Copy-Item $File.FullName $DestPath -Force
            }
            
            # Process template variables if template.json exists
            $TemplateConfigPath = Join-Path $SelectedTemplate.FullName "template.json"
            if (Test-Path $TemplateConfigPath) {
                try {
                    # Replace variables in files
                    $FilesToProcess = Get-ChildItem $ProjectPath -Recurse -File | Where-Object { 
                        $_.Extension -in @('.md', '.txt', '.json', '.py', '.js', '.ts', '.html', '.css', '.ps1') 
                    }
                    
                    foreach ($File in $FilesToProcess) {
                        $Content = Get-Content $File.FullName -Raw
                        $Content = $Content -replace '\{\{PROJECT_NAME\}\}', $RepoName
                        $Content = $Content -replace '\{\{PROJECT_DESCRIPTION\}\}', $Notes
                        $Content = $Content -replace '\{\{DATE\}\}', (Get-Date -Format "MMMM dd, yyyy")
                        $Content = $Content -replace '\{\{GITHUB_USERNAME\}\}', $GitHubUsername
                        
                        $Content | Set-Content $File.FullName -Encoding UTF8
                    }
                }
                catch {
                    Write-Host "⚠️ Warning: Could not process template variables" -ForegroundColor Yellow
                }
            }
            
            Write-Host "✅ Template applied successfully!" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️ Warning: Template application failed: $_" -ForegroundColor Yellow
            Write-Host "Continuing with basic setup..." -ForegroundColor Yellow
        }
    }
    
    # Create or update README file
    if (!(Test-Path "README.md") -or $SelectedTemplate) {
        Write-Host "Creating README file..." -ForegroundColor Cyan
        $ReadmeContent = @"
# $RepoName

$Notes

## Getting Started

This project was created on $(Get-Date -Format "MMMM dd, yyyy") using the Enhanced GitHub Project Creator.

$(if ($SelectedTemplate) { "**Template Used:** $($SelectedTemplate.Name)" })

## Description

$Notes

## Next Steps

- [ ] Add your project files
- [ ] Update this README with more details
- [ ] Start coding!

---

*This README was generated automatically. Feel free to customize it for your project.*
"@
        
        $ReadmeContent | Out-File -FilePath "README.md" -Encoding UTF8
    }
    
    # Add, commit, and push the changes
    Write-Host "Creating initial commit..." -ForegroundColor Cyan
    git add .
    git commit -m "Initial commit$(if ($SelectedTemplate) { " with $($SelectedTemplate.Name) template" })"
    git push -u origin main
}

# Check if VS Code is available and open the project
Write-Host "Opening project in VS Code..." -ForegroundColor Cyan
try {
    code .
    Write-Host "✅ Project opened in VS Code!" -ForegroundColor Green
}
catch {
    Write-Host "⚠️  VS Code not found. You can manually open the folder: $ProjectPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 All done! Your project is ready!" -ForegroundColor Green
Write-Host ""
if ($Mode -eq "2") {
    Write-Host "Cloned project location: $ProjectPath" -ForegroundColor Cyan
    Write-Host "Original repository: $RepoUrl" -ForegroundColor Cyan
} else {
    Write-Host "Project location: $ProjectPath" -ForegroundColor Cyan
    Write-Host "GitHub URL: https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Magenta

# Keep the window open so user can see the results
Read-Host "Press Enter to close this window"
