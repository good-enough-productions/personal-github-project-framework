# Template Manager for GitHub Project Creator
# Manage, create, and maintain project templates

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("list", "create", "edit", "delete", "info")]
    [string]$Action = "list",
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateName,
    
    [Parameter(Mandatory=$false)]
    [string]$TemplatesPath
)

# Set default templates path
if (-not $TemplatesPath) {
    $TemplatesPath = Join-Path (Split-Path $PSScriptRoot -Parent) "templates"
}

# Ensure templates directory exists
if (!(Test-Path $TemplatesPath)) {
    New-Item -ItemType Directory -Path $TemplatesPath -Force | Out-Null
    Write-Host "✅ Created templates directory: $TemplatesPath" -ForegroundColor Green
}

function Show-AllTemplates {
    Write-Host "=== Available Project Templates ===" -ForegroundColor Cyan
    
    $Templates = Get-ChildItem $TemplatesPath -Directory
    
    if ($Templates.Count -eq 0) {
        Write-Host "No templates found in $TemplatesPath" -ForegroundColor Yellow
        return
    }
    
    foreach ($Template in $Templates) {
        $ConfigFile = Join-Path $Template.FullName "template.json"
        $Name = $Template.Name
        $Description = "No description available"
        $Technologies = @()
        
        if (Test-Path $ConfigFile) {
            try {
                $Config = Get-Content $ConfigFile | ConvertFrom-Json
                $Description = $Config.description
                $Technologies = $Config.technologies
            }
            catch {
                Write-Warning "Could not read config for $Name"
            }
        }
        
        Write-Host ""
        Write-Host "📁 $Name" -ForegroundColor Green
        Write-Host "   Description: $Description" -ForegroundColor White
        if ($Technologies) {
            Write-Host "   Technologies: $($Technologies -join ', ')" -ForegroundColor Cyan
        }
        
        # Show file count
        $FileCount = (Get-ChildItem $Template.FullName -Recurse -File | Measure-Object).Count
        Write-Host "   Files: $FileCount" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "💡 Usage: .\Template-Manager.ps1 -Action info -TemplateName 'template-name'" -ForegroundColor Yellow
}

function Show-TemplateInfo {
    param([string]$Name)
    
    $TemplatePath = Join-Path $TemplatesPath $Name
    
    if (!(Test-Path $TemplatePath)) {
        Write-Host "❌ Template '$Name' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "=== Template Information: $Name ===" -ForegroundColor Cyan
    
    $ConfigFile = Join-Path $TemplatePath "template.json"
    if (Test-Path $ConfigFile) {
        try {
            $Config = Get-Content $ConfigFile | ConvertFrom-Json
            
            Write-Host ""
            Write-Host "Name: $($Config.name)" -ForegroundColor Green
            Write-Host "Description: $($Config.description)" -ForegroundColor White
            Write-Host "Category: $($Config.category)" -ForegroundColor Cyan
            Write-Host "Technologies: $($Config.technologies -join ', ')" -ForegroundColor Cyan
            
            if ($Config.variables) {
                Write-Host ""
                Write-Host "Template Variables:" -ForegroundColor Yellow
                $Config.variables.PSObject.Properties | ForEach-Object {
                    Write-Host "  {{$($_.Name)}} - $($_.Value)" -ForegroundColor Gray
                }
            }
        }
        catch {
            Write-Warning "Could not read template configuration"
        }
    }
    
    Write-Host ""
    Write-Host "Template Structure:" -ForegroundColor Yellow
    Get-ChildItem $TemplatePath -Recurse | ForEach-Object {
        $RelativePath = $_.FullName.Replace($TemplatePath, "").TrimStart('\')
        if ($_.PSIsContainer) {
            Write-Host "  📁 $RelativePath/" -ForegroundColor Cyan
        } else {
            Write-Host "  📄 $RelativePath" -ForegroundColor White
        }
    }
}

function New-Template {
    param([string]$Name)
    
    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = Read-Host "Enter template name (lowercase, hyphens allowed)"
    }
    
    # Validate name
    if ($Name -notmatch '^[a-z0-9-]+$') {
        Write-Host "❌ Template name must be lowercase with hyphens only" -ForegroundColor Red
        return
    }
    
    $TemplatePath = Join-Path $TemplatesPath $Name
    
    if (Test-Path $TemplatePath) {
        Write-Host "❌ Template '$Name' already exists" -ForegroundColor Red
        return
    }
    
    Write-Host "Creating new template: $Name" -ForegroundColor Cyan
    
    # Get template information
    $DisplayName = Read-Host "Enter display name"
    $Description = Read-Host "Enter description"
    $Category = Read-Host "Enter category (e.g., web, automation, data)"
    $Technologies = Read-Host "Enter technologies (comma-separated)"
    
    # Create template directory
    New-Item -ItemType Directory -Path $TemplatePath -Force | Out-Null
    
    # Create template.json
    $TechArray = $Technologies -split ',' | ForEach-Object { $_.Trim() }
    $Config = @{
        name = $DisplayName
        description = $Description
        category = $Category
        technologies = $TechArray
        variables = @{
            PROJECT_NAME = "Project name"
            PROJECT_DESCRIPTION = "Project description"
            DATE = "Current date"
            GITHUB_USERNAME = "GitHub username"
        }
    }
    
    $Config | ConvertTo-Json -Depth 3 | Out-File -FilePath (Join-Path $TemplatePath "template.json") -Encoding UTF8
    
    # Create basic README template
    $ReadmeContent = @"
# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Getting Started

Add your setup instructions here.

## Usage

Add usage instructions here.

## Features

- Feature 1
- Feature 2
- Feature 3

## Notes

Created on {{DATE}} using Enhanced GitHub Project Creator.

---

*This project was generated from the $DisplayName template.*
"@
    
    $ReadmeContent | Out-File -FilePath (Join-Path $TemplatePath "README.md") -Encoding UTF8
    
    Write-Host "✅ Template '$Name' created successfully!" -ForegroundColor Green
    Write-Host "📁 Location: $TemplatePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Add your template files to: $TemplatePath" -ForegroundColor White
    Write-Host "2. Use {{PROJECT_NAME}}, {{PROJECT_DESCRIPTION}}, etc. for variables" -ForegroundColor White
    Write-Host "3. Test with: Create-Project-Enhanced.bat" -ForegroundColor White
}

function Remove-Template {
    param([string]$Name)
    
    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = Read-Host "Enter template name to delete"
    }
    
    $TemplatePath = Join-Path $TemplatesPath $Name
    
    if (!(Test-Path $TemplatePath)) {
        Write-Host "❌ Template '$Name' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "⚠️  This will permanently delete the template: $Name" -ForegroundColor Yellow
    $Confirm = Read-Host "Are you sure? (type 'yes' to confirm)"
    
    if ($Confirm -eq "yes") {
        Remove-Item $TemplatePath -Recurse -Force
        Write-Host "✅ Template '$Name' deleted successfully" -ForegroundColor Green
    } else {
        Write-Host "Operation cancelled" -ForegroundColor Gray
    }
}

function Edit-Template {
    param([string]$Name)
    
    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = Read-Host "Enter template name to edit"
    }
    
    $TemplatePath = Join-Path $TemplatesPath $Name
    
    if (!(Test-Path $TemplatePath)) {
        Write-Host "❌ Template '$Name' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "Opening template in VS Code: $Name" -ForegroundColor Cyan
    
    try {
        code $TemplatePath
        Write-Host "✅ Template opened in VS Code" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Could not open VS Code. Template location: $TemplatePath" -ForegroundColor Red
    }
}

# Main execution
switch ($Action.ToLower()) {
    "list" {
        Show-AllTemplates
    }
    "info" {
        if ($TemplateName) {
            Show-TemplateInfo -Name $TemplateName
        } else {
            Write-Host "❌ Please specify template name with -TemplateName" -ForegroundColor Red
        }
    }
    "create" {
        New-Template -Name $TemplateName
    }
    "edit" {
        Edit-Template -Name $TemplateName
    }
    "delete" {
        Remove-Template -Name $TemplateName
    }
    default {
        Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: list, info, create, edit, delete" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "💡 Template Manager Usage:" -ForegroundColor Cyan
Write-Host "  List templates:    .\Template-Manager.ps1" -ForegroundColor White
Write-Host "  Template info:     .\Template-Manager.ps1 -Action info -TemplateName 'name'" -ForegroundColor White
Write-Host "  Create template:   .\Template-Manager.ps1 -Action create" -ForegroundColor White
Write-Host "  Edit template:     .\Template-Manager.ps1 -Action edit -TemplateName 'name'" -ForegroundColor White
Write-Host "  Delete template:   .\Template-Manager.ps1 -Action delete -TemplateName 'name'" -ForegroundColor White
