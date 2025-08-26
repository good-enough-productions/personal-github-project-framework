# Project Synergy Finder
# Analyzes your projects to find integration opportunities and suggest combinations

param(
    [Parameter(Mandatory=$false)]
    [string]$CatalogPath = "C:\Users\dschm\OneDrive\Desktop\Active Github Projects\project-catalog.json",
    
    [Parameter(Mandatory=$false)]
    [string]$FocusProject,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowIntegrationIdeas,
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateExamples
)

# Load project catalog
if (-not (Test-Path $CatalogPath)) {
    Write-Host "❌ Project catalog not found. Run Discover-Projects.ps1 first." -ForegroundColor Red
    exit 1
}

$Projects = Get-Content $CatalogPath | ConvertFrom-Json
Write-Host "=== Project Synergy Analysis ===" -ForegroundColor Cyan
Write-Host "Loaded $($Projects.Count) projects from catalog" -ForegroundColor Yellow

# Function to calculate project similarity
function Get-ProjectSimilarity {
    param($Project1, $Project2)
    
    $Score = 0
    
    # Technology overlap
    $CommonTech = $Project1.Technologies | Where-Object { $_ -in $Project2.Technologies }
    $Score += ($CommonTech.Count * 10)
    
    # Language compatibility  
    $CommonLang = $Project1.Languages | Where-Object { $_ -in $Project2.Languages }
    $Score += ($CommonLang.Count * 5)
    
    # Similar project types
    if ($Project1.Type -eq $Project2.Type) { $Score += 15 }
    
    # Size compatibility (similar sized projects often work well together)
    $SizeDiff = [Math]::Abs($Project1.TotalLines - $Project2.TotalLines)
    if ($SizeDiff -lt 1000) { $Score += 10 }
    elseif ($SizeDiff -lt 5000) { $Score += 5 }
    
    return $Score
}

# Function to suggest integration patterns
function Get-IntegrationSuggestions {
    param($Project1, $Project2, $SimilarityScore)
    
    $Suggestions = @()
    
    # API integration patterns
    if ($Project1.Technologies -contains "FastAPI" -and $Project2.Technologies -contains "JavaScript") {
        $Suggestions += "Create a web frontend ($($Project2.Name)) that consumes the API from $($Project1.Name)"
    }
    
    if ($Project1.Technologies -contains "PowerShell" -and $Project2.Type -eq "Python") {
        $Suggestions += "Use PowerShell automation ($($Project1.Name)) to orchestrate Python workflows ($($Project2.Name))"
    }
    
    # Data pipeline patterns
    if ($Project1.Description -match "data|csv|excel|database" -and $Project2.Description -match "analysis|visualization|report") {
        $Suggestions += "Feed data from $($Project1.Name) into analysis workflows in $($Project2.Name)"
    }
    
    # Automation chains
    if ($Project1.Technologies -contains "PowerShell" -and $Project2.Technologies -contains "PowerShell") {
        $Suggestions += "Chain these PowerShell scripts together into a larger automation workflow"
    }
    
    # UI + Backend patterns
    if ($Project1.Technologies -contains "React" -and $Project2.Technologies -contains "Python") {
        $Suggestions += "Build a full-stack application with React frontend ($($Project1.Name)) and Python backend ($($Project2.Name))"
    }
    
    # Generic high-similarity suggestions
    if ($SimilarityScore -gt 30) {
        $Suggestions += "High compatibility - consider merging similar functionality or creating a unified version"
    }
    
    return $Suggestions
}

# Analyze all project pairs
$Synergies = @()

for ($i = 0; $i -lt $Projects.Count; $i++) {
    for ($j = $i + 1; $j -lt $Projects.Count; $j++) {
        $Project1 = $Projects[$i]
        $Project2 = $Projects[$j]
        
        $Similarity = Get-ProjectSimilarity -Project1 $Project1 -Project2 $Project2
        
        if ($Similarity -gt 10) {  # Only show meaningful connections
            $Integrations = Get-IntegrationSuggestions -Project1 $Project1 -Project2 $Project2 -SimilarityScore $Similarity
            
            $Synergies += @{
                Project1 = $Project1.Name
                Project2 = $Project2.Name
                SimilarityScore = $Similarity
                CommonTechnologies = ($Project1.Technologies | Where-Object { $_ -in $Project2.Technologies })
                IntegrationIdeas = $Integrations
                Project1Path = $Project1.Path
                Project2Path = $Project2.Path
                Project1Type = $Project1.Type
                Project2Type = $Project2.Type
            }
        }
    }
}

# Sort by similarity score
$Synergies = $Synergies | Sort-Object SimilarityScore -Descending

# Display results
if ($FocusProject) {
    Write-Host ""
    Write-Host "=== Synergies for '$FocusProject' ===" -ForegroundColor Green
    $FocusedSynergies = $Synergies | Where-Object { $_.Project1 -like "*$FocusProject*" -or $_.Project2 -like "*$FocusProject*" }
    
    if ($FocusedSynergies) {
        foreach ($Synergy in $FocusedSynergies) {
            $OtherProject = if ($Synergy.Project1 -like "*$FocusProject*") { $Synergy.Project2 } else { $Synergy.Project1 }
            Write-Host ""
            Write-Host "🔗 $OtherProject (Score: $($Synergy.SimilarityScore))" -ForegroundColor Cyan
            if ($Synergy.CommonTechnologies) {
                Write-Host "   Shared: $($Synergy.CommonTechnologies -join ', ')" -ForegroundColor Gray
            }
            if ($Synergy.IntegrationIdeas) {
                foreach ($Idea in $Synergy.IntegrationIdeas) {
                    Write-Host "   💡 $Idea" -ForegroundColor Yellow
                }
            }
        }
    } else {
        Write-Host "No significant synergies found for '$FocusProject'" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "=== Top Project Synergies ===" -ForegroundColor Green
    
    $TopSynergies = $Synergies | Select-Object -First 10
    
    foreach ($Synergy in $TopSynergies) {
        Write-Host ""
        Write-Host "🔗 $($Synergy.Project1) ↔ $($Synergy.Project2)" -ForegroundColor Cyan
        Write-Host "   Score: $($Synergy.SimilarityScore) | Types: $($Synergy.Project1Type) + $($Synergy.Project2Type)" -ForegroundColor Gray
        
        if ($Synergy.CommonTechnologies) {
            Write-Host "   Shared Technologies: $($Synergy.CommonTechnologies -join ', ')" -ForegroundColor White
        }
        
        if ($ShowIntegrationIdeas -and $Synergy.IntegrationIdeas) {
            foreach ($Idea in $Synergy.IntegrationIdeas) {
                Write-Host "   💡 $Idea" -ForegroundColor Yellow
            }
        }
    }
}

# Technology cluster analysis
Write-Host ""
Write-Host "=== Technology Clusters ===" -ForegroundColor Green

$TechGroups = $Projects | Group-Object { $_.Technologies -join "," } | Where-Object { $_.Count -gt 1 }
foreach ($Group in $TechGroups) {
    Write-Host ""
    Write-Host "📚 $($Group.Name) ($($Group.Count) projects):" -ForegroundColor Cyan
    foreach ($Project in $Group.Group) {
        Write-Host "   - $($Project.Name)" -ForegroundColor White
    }
    Write-Host "   💡 These could be combined into a unified toolkit" -ForegroundColor Yellow
}

# Generate integration examples
if ($GenerateExamples) {
    Write-Host ""
    Write-Host "=== Integration Code Examples ===" -ForegroundColor Green
    
    $TopSynergy = $Synergies | Select-Object -First 1
    if ($TopSynergy) {
        Write-Host ""
        Write-Host "Example: Connecting $($TopSynergy.Project1) and $($TopSynergy.Project2)" -ForegroundColor Cyan
        
        # Generate example based on project types
        if ($TopSynergy.Project1Type -eq "PowerShell" -and $TopSynergy.Project2Type -eq "Python") {
            Write-Host @"
# PowerShell script to call Python
`$pythonScript = "$($TopSynergy.Project2Path)\main.py"
`$result = python `$pythonScript --input "data.csv"
Write-Host "Python processing complete: `$result"
"@ -ForegroundColor Gray
        }
        
        if ($TopSynergy.CommonTechnologies -contains "JavaScript") {
            Write-Host @"
// JavaScript integration example
import { processData } from './$($TopSynergy.Project1)';
import { visualizeResults } from './$($TopSynergy.Project2)';

const data = processData(inputData);
const chart = visualizeResults(data);
"@ -ForegroundColor Gray
        }
    }
}

# Suggestions for workflow improvement
Write-Host ""
Write-Host "=== Workflow Optimization Suggestions ===" -ForegroundColor Green

$PowerShellProjects = $Projects | Where-Object { $_.Technologies -contains "PowerShell" }
if ($PowerShellProjects.Count -gt 2) {
    Write-Host "💡 You have $($PowerShellProjects.Count) PowerShell projects - consider creating a shared module library" -ForegroundColor Yellow
}

$PythonProjects = $Projects | Where-Object { $_.Technologies -contains "Python" }
if ($PythonProjects.Count -gt 2) {
    Write-Host "💡 You have $($PythonProjects.Count) Python projects - consider standardizing with a common requirements.txt template" -ForegroundColor Yellow
}

$RecentProjects = $Projects | Where-Object { $_.LastModified -gt (Get-Date).AddDays(-30) }
if ($RecentProjects.Count -gt 5) {
    Write-Host "💡 You've been very active! Consider using project templates to speed up common patterns" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Analysis complete!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Next steps:" -ForegroundColor Cyan
Write-Host "  - Focus on high-scoring synergies for integration opportunities" -ForegroundColor White
Write-Host "  - Consider creating shared libraries for common technologies" -ForegroundColor White
Write-Host "  - Use LM-Assistant.ps1 to get detailed integration advice" -ForegroundColor White
