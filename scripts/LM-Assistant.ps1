# LM Studio Integration for Project Analysis
# This script connects to your local LM Studio instance for intelligent project assistance

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$Question,
    
    [Parameter(Mandatory=$false)]
    [string]$Action = "explain",  # explain, analyze, suggest, document, troubleshoot
    
    [Parameter(Mandatory=$false)]
    [string]$LMStudioUrl = "http://localhost:1234"
)

# Configuration
$MaxTokens = 1000
$Temperature = 0.7

# Function to call LM Studio API
function Invoke-LMStudio {
    param(
        [string]$Prompt,
        [string]$SystemMessage = "You are a helpful coding assistant."
    )
    
    $Body = @{
        model = "local-model"  # LM Studio uses this placeholder
        messages = @(
            @{
                role = "system"
                content = $SystemMessage
            },
            @{
                role = "user" 
                content = $Prompt
            }
        )
        max_tokens = $MaxTokens
        temperature = $Temperature
    } | ConvertTo-Json -Depth 3

    try {
        $Response = Invoke-RestMethod -Uri "$LMStudioUrl/v1/chat/completions" -Method POST -Body $Body -ContentType "application/json"
        return $Response.choices[0].message.content
    }
    catch {
        Write-Host "❌ Error connecting to LM Studio: $_" -ForegroundColor Red
        Write-Host "Make sure LM Studio is running on $LMStudioUrl" -ForegroundColor Yellow
        return $null
    }
}

# Function to analyze project structure
function Get-ProjectInfo {
    param([string]$Path)
    
    $ProjectInfo = @{
        Name = Split-Path $Path -Leaf
        Path = $Path
        Files = @()
        Languages = @()
        Size = 0
    }
    
    if (Test-Path $Path) {
        $Files = Get-ChildItem $Path -Recurse -File | Where-Object { 
            $_.Extension -in @('.ps1', '.py', '.js', '.ts', '.html', '.css', '.md', '.json', '.yml', '.yaml', '.txt') 
        }
        
        $ProjectInfo.Files = $Files | ForEach-Object {
            @{
                Name = $_.Name
                Extension = $_.Extension
                Size = $_.Length
                RelativePath = $_.FullName.Replace($Path, "").TrimStart('\')
            }
        }
        
        $ProjectInfo.Languages = $Files | Group-Object Extension | ForEach-Object { $_.Name }
        $ProjectInfo.Size = ($Files | Measure-Object Length -Sum).Sum
    }
    
    return $ProjectInfo
}

# Function to read relevant files for context
function Get-ProjectContext {
    param([string]$Path, [int]$MaxFiles = 5)
    
    $ContextFiles = @()
    $ImportantFiles = @('README.md', 'package.json', 'requirements.txt', '*.ps1', '*.py', '*.js')
    
    foreach ($Pattern in $ImportantFiles) {
        $Files = Get-ChildItem $Path -Filter $Pattern -Recurse | Select-Object -First $MaxFiles
        foreach ($File in $Files) {
            if ($File.Length -lt 10KB) {  # Only include small files
                $Content = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
                if ($Content) {
                    $ContextFiles += @{
                        Path = $File.FullName.Replace($Path, "").TrimStart('\')
                        Content = $Content.Substring(0, [Math]::Min($Content.Length, 2000))  # Limit content size
                    }
                }
            }
        }
    }
    
    return $ContextFiles
}

# Main execution
Write-Host "=== LM Studio Project Assistant ===" -ForegroundColor Cyan
Write-Host "Analyzing project: $ProjectPath" -ForegroundColor Yellow

# Test LM Studio connection
Write-Host "Testing LM Studio connection..." -ForegroundColor Cyan
$TestResponse = Invoke-LMStudio -Prompt "Hello, are you working?" -SystemMessage "Respond with just 'Yes, I'm ready to help!'"

if (-not $TestResponse) {
    Write-Host "❌ Cannot connect to LM Studio. Please:" -ForegroundColor Red
    Write-Host "  1. Start LM Studio" -ForegroundColor White
    Write-Host "  2. Load a model" -ForegroundColor White
    Write-Host "  3. Start the local server" -ForegroundColor White
    Write-Host "  4. Verify it's running on $LMStudioUrl" -ForegroundColor White
    exit 1
}

Write-Host "✅ Connected to LM Studio!" -ForegroundColor Green
Write-Host "Response: $TestResponse" -ForegroundColor Gray

# Analyze project
$ProjectInfo = Get-ProjectInfo -Path $ProjectPath
$Context = Get-ProjectContext -Path $ProjectPath

# Build prompt based on action
$SystemMessage = "You are an expert developer assistant. Analyze the provided project information and code, then provide helpful insights in a clear, organized manner."

$Prompt = switch ($Action.ToLower()) {
    "explain" {
        @"
Please analyze this project and explain:
1. What this project does (main purpose)
2. How it works (key components)
3. How to use it (basic instructions)
4. What technologies it uses

Project: $($ProjectInfo.Name)
Languages: $($ProjectInfo.Languages -join ', ')
Files: $($ProjectInfo.Files.Count)

Key Files:
$($Context | ForEach-Object { "File: $($_.Path)`n$($_.Content)`n---`n" } | Out-String)
"@
    }
    "analyze" {
        @"
Please perform a technical analysis of this project:
1. Code quality and structure
2. Potential issues or improvements
3. Missing components or documentation
4. Security considerations
5. Performance implications

Project: $($ProjectInfo.Name)
Languages: $($ProjectInfo.Languages -join ', ')

Code Files:
$($Context | ForEach-Object { "File: $($_.Path)`n$($_.Content)`n---`n" } | Out-String)
"@
    }
    "suggest" {
        @"
Please suggest enhancements for this project:
1. Feature additions that would be valuable
2. Integration opportunities with other tools
3. Automation improvements
4. User experience enhancements
5. Ways to make it more maintainable

Project: $($ProjectInfo.Name)
Current state:
$($Context | ForEach-Object { "File: $($_.Path)`n$($_.Content)`n---`n" } | Out-String)
"@
    }
    "document" {
        @"
Please generate documentation for this project:
1. A clear README section
2. Installation/setup instructions
3. Usage examples
4. API/function documentation if applicable
5. Troubleshooting tips

Project to document: $($ProjectInfo.Name)
Code to document:
$($Context | ForEach-Object { "File: $($_.Path)`n$($_.Content)`n---`n" } | Out-String)
"@
    }
    "troubleshoot" {
        @"
Please help troubleshoot this project:
1. Common issues users might encounter
2. Debug steps for problems
3. Environment requirements
4. Dependencies that might cause issues
5. How to verify everything is working

Project: $($ProjectInfo.Name)
Code:
$($Context | ForEach-Object { "File: $($_.Path)`n$($_.Content)`n---`n" } | Out-String)

User question: $Question
"@
    }
    default {
        if ($Question) {
            @"
User question about the project '$($ProjectInfo.Name)': $Question

Project context:
$($Context | ForEach-Object { "File: $($_.Path)`n$($_.Content)`n---`n" } | Out-String)
"@
        } else {
            "Please explain what this project does and how to use it."
        }
    }
}

# Get LLM response
Write-Host "Getting analysis from local LLM..." -ForegroundColor Cyan
$Response = Invoke-LMStudio -Prompt $Prompt -SystemMessage $SystemMessage

if ($Response) {
    Write-Host ""
    Write-Host "=== Analysis Results ===" -ForegroundColor Green
    Write-Host $Response
    
    # Save response to file
    $OutputFile = Join-Path $ProjectPath "LLM-Analysis-$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"
    $MarkdownContent = @"
# LLM Analysis: $($ProjectInfo.Name)

**Date:** $(Get-Date -Format "MMMM dd, yyyy 'at' h:mm tt")  
**Action:** $Action  
**Question:** $Question  

## Analysis

$Response

---
*Generated by LM Studio Project Assistant*
"@
    
    $MarkdownContent | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host ""
    Write-Host "✅ Analysis saved to: $OutputFile" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to get response from LM Studio" -ForegroundColor Red
}

# Usage examples
Write-Host ""
Write-Host "💡 Usage Examples:" -ForegroundColor Cyan
Write-Host "  .\LM-Assistant.ps1 -Action explain" -ForegroundColor White
Write-Host "  .\LM-Assistant.ps1 -Action analyze -ProjectPath 'C:\MyProject'" -ForegroundColor White
Write-Host "  .\LM-Assistant.ps1 -Question 'How do I run this script?'" -ForegroundColor White
Write-Host "  .\LM-Assistant.ps1 -Action suggest" -ForegroundColor White
