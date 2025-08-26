# Context Template Manager
# Manages AI context templates for better LLM interactions

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("list", "combine", "update", "create-prompt", "help")]
    [string]$Action = "list",
    
    [Parameter(Mandatory=$false)]
    [string[]]$Templates,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectContext
)

$ContextTemplatesPath = Join-Path (Split-Path $PSScriptRoot -Parent) "context-templates"

function Show-AvailableTemplates {
    Write-Host "=== Available Context Templates ===" -ForegroundColor Cyan
    Write-Host ""
    
    if (!(Test-Path $ContextTemplatesPath)) {
        Write-Host "❌ Context templates directory not found: $ContextTemplatesPath" -ForegroundColor Red
        return
    }
    
    $Templates = Get-ChildItem $ContextTemplatesPath -Filter "*.md"
    
    foreach ($Template in $Templates) {
        $Name = $Template.BaseName
        $Content = Get-Content $Template.FullName -Raw
        
        # Extract first description line
        $Description = "No description available"
        if ($Content -match '# (.+)') {
            $Description = $Matches[1]
        }
        
        Write-Host "📄 $Name" -ForegroundColor Green
        Write-Host "   $Description" -ForegroundColor White
        
        # Show key sections
        $Sections = [regex]::Matches($Content, '## (.+)')
        if ($Sections.Count -gt 0) {
            $SectionNames = $Sections | ForEach-Object { $_.Groups[1].Value } | Select-Object -First 3
            Write-Host "   Sections: $($SectionNames -join ', ')$(if ($Sections.Count -gt 3) { '...' })" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    Write-Host "💡 Usage examples:" -ForegroundColor Yellow
    Write-Host "  Combine templates:    .\Context-Manager.ps1 -Action combine -Templates 'personal-profile','tools-and-preferences'" -ForegroundColor White
    Write-Host "  Create chat prompt:   .\Context-Manager.ps1 -Action create-prompt -Templates 'communication-preferences'" -ForegroundColor White
    Write-Host "  Update template:      .\Context-Manager.ps1 -Action update" -ForegroundColor White
}

function Join-Templates {
    param([string[]]$TemplateNames, [string]$Output)
    
    Write-Host "=== Combining Context Templates ===" -ForegroundColor Cyan
    
    if (-not $TemplateNames -or $TemplateNames.Count -eq 0) {
        Write-Host "❌ No templates specified. Use -Templates parameter." -ForegroundColor Red
        return
    }
    
    $CombinedContent = @()
    $CombinedContent += "# Combined Context for AI Assistant"
    $CombinedContent += ""
    $CombinedContent += "*Generated on $(Get-Date -Format 'MMMM dd, yyyy at h:mm tt')*"
    $CombinedContent += "*Templates: $($TemplateNames -join ', ')*"
    $CombinedContent += ""
    
    foreach ($TemplateName in $TemplateNames) {
        $TemplateFile = Join-Path $ContextTemplatesPath "$TemplateName.md"
        
        if (!(Test-Path $TemplateFile)) {
            Write-Host "⚠️ Template not found: $TemplateName" -ForegroundColor Yellow
            continue
        }
        
        Write-Host "Adding template: $TemplateName" -ForegroundColor Green
        
        $Content = Get-Content $TemplateFile -Raw
        
        # Remove the main title and add as section
        $Content = $Content -replace '^# .+\r?\n', ''
        $CombinedContent += "---"
        $CombinedContent += ""
        $CombinedContent += "# Context: $TemplateName"
        $CombinedContent += ""
        $CombinedContent += $Content.Trim()
        $CombinedContent += ""
    }
    
    $CombinedContent += "---"
    $CombinedContent += ""
    $CombinedContent += "## Instructions for AI Assistant"
    $CombinedContent += ""
    $CombinedContent += "Please use all the above context when helping me with projects. This includes:"
    $CombinedContent += "- My skill level and learning preferences"
    $CombinedContent += "- Tool and technology preferences"
    $CombinedContent += "- Communication style preferences"
    $CombinedContent += "- Current development environment and setup"
    $CombinedContent += ""
    $CombinedContent += "Always consider this context when suggesting solutions, explaining concepts, or recommending tools."
    
    # Output to file or console
    if ($Output) {
        $CombinedContent | Out-File -FilePath $Output -Encoding UTF8
        Write-Host "✅ Combined context saved to: $Output" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "=== Combined Context ===" -ForegroundColor Green
        $CombinedContent | ForEach-Object { Write-Host $_ }
    }
}

function New-ChatPrompt {
    param([string[]]$TemplateNames, [string]$Project)
    
    Write-Host "=== Creating Chat Prompt ===" -ForegroundColor Cyan
    
    if (-not $TemplateNames -or $TemplateNames.Count -eq 0) {
        $TemplateNames = @("personal-profile", "communication-preferences")
        Write-Host "Using default templates: $($TemplateNames -join ', ')" -ForegroundColor Yellow
    }
    
    $Prompt = @()
    $Prompt += "I'm going to share some context about myself and my preferences to help you assist me better."
    $Prompt += ""
    
    foreach ($TemplateName in $TemplateNames) {
        $TemplateFile = Join-Path $ContextTemplatesPath "$TemplateName.md"
        
        if (Test-Path $TemplateFile) {
            $Content = Get-Content $TemplateFile -Raw
            $Prompt += "## $TemplateName Context:"
            $Prompt += "``````"
            $Prompt += $Content
            $Prompt += "``````"
            $Prompt += ""
        }
    }
    
    if ($Project) {
        $Prompt += "## Current Project Context:"
        $Prompt += $Project
        $Prompt += ""
    }
    
    $Prompt += "Please acknowledge that you've read and understood this context, and let me know you're ready to help with my project using these preferences."
    
    # Copy to clipboard if possible
    try {
        $Prompt -join "`n" | Set-Clipboard
        Write-Host "✅ Chat prompt copied to clipboard!" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ Could not copy to clipboard. Here's the prompt:" -ForegroundColor Yellow
        Write-Host ""
        $Prompt | ForEach-Object { Write-Host $_ }
    }
}

function Update-Templates {
    Write-Host "=== Update Context Templates ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Opening context templates directory in VS Code..." -ForegroundColor Yellow
    
    try {
        code $ContextTemplatesPath
        Write-Host "✅ Templates opened in VS Code" -ForegroundColor Green
        Write-Host ""
        Write-Host "💡 Tips for updating templates:" -ForegroundColor Cyan
        Write-Host "  - Keep information current and relevant" -ForegroundColor White
        Write-Host "  - Update skills and tool preferences as they change" -ForegroundColor White
        Write-Host "  - Add new tools or services you start using" -ForegroundColor White
        Write-Host "  - Remove or update outdated information" -ForegroundColor White
    }
    catch {
        Write-Host "❌ Could not open VS Code. Template location: $ContextTemplatesPath" -ForegroundColor Red
    }
}

function Show-Help {
    Write-Host "=== Context Template Manager Help ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This tool manages AI context templates - profiles that help LLMs understand" -ForegroundColor White
    Write-Host "your preferences, skills, and working style for better assistance." -ForegroundColor White
    Write-Host ""
    Write-Host "Available Actions:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 list (default)" -ForegroundColor Green
    Write-Host "   Shows all available context templates" -ForegroundColor White
    Write-Host "   Usage: .\Context-Manager.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔗 combine" -ForegroundColor Green
    Write-Host "   Combines multiple templates into a single context document" -ForegroundColor White
    Write-Host "   Usage: .\Context-Manager.ps1 -Action combine -Templates 'personal-profile','tools-and-preferences' -OutputFile 'my-context.md'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💬 create-prompt" -ForegroundColor Green
    Write-Host "   Creates a ready-to-paste prompt for AI chat interfaces" -ForegroundColor White
    Write-Host "   Usage: .\Context-Manager.ps1 -Action create-prompt -Templates 'communication-preferences'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✏️ update" -ForegroundColor Green
    Write-Host "   Opens templates in VS Code for editing" -ForegroundColor White
    Write-Host "   Usage: .\Context-Manager.ps1 -Action update" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Template Types:" -ForegroundColor Yellow
    Write-Host "  personal-profile       - Background, goals, learning preferences" -ForegroundColor White
    Write-Host "  tools-and-preferences  - Technology stack and tool preferences" -ForegroundColor White
    Write-Host "  credentials-and-environment - System config and file paths" -ForegroundColor White
    Write-Host "  communication-preferences - How to interact with you effectively" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Pro Tips:" -ForegroundColor Cyan
    Write-Host "  - Use create-prompt for quick AI chat setup" -ForegroundColor White
    Write-Host "  - Combine templates for comprehensive project context" -ForegroundColor White
    Write-Host "  - Update templates regularly as your skills and preferences evolve" -ForegroundColor White
    Write-Host "  - Include project-specific context when working on specific features" -ForegroundColor White
}

# Main execution
switch ($Action.ToLower()) {
    "list" {
        Show-AvailableTemplates
    }
    "combine" {
        Join-Templates -TemplateNames $Templates -Output $OutputFile
    }
    "create-prompt" {
        New-ChatPrompt -TemplateNames $Templates -Project $ProjectContext
    }
    "update" {
        Update-Templates
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Use -Action help for usage information" -ForegroundColor Yellow
    }
}
