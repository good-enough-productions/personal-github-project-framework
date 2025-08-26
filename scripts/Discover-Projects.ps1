# Project Discovery and Cataloging System
# Automatically finds, analyzes, and catalogs all your coding projects

param(
    [Parameter(Mandatory=$false)]
    [string]$ScanPath = "C:\Users\dschm\Documents",
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoAnalyze,
    
    [Parameter(Mandatory=$false)]
    [switch]$UpdateExisting,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Users\dschm\OneDrive\Desktop\Active Github Projects\project-catalog.json"
)

# Configuration
$ProjectIndicators = @(
    "package.json", "requirements.txt", "*.sln", "*.csproj", "*.py", "*.ps1", 
    "*.js", "*.ts", "Dockerfile", "docker-compose.yml", ".git", "README.md"
)

$IgnoredPaths = @(
    "node_modules", ".git", "__pycache__", "bin", "obj", ".vs", ".vscode", 
    "dist", "build", "target", ".next", ".nuxt"
)

# Function to detect if a directory is a project
function Test-IsProject {
    param([string]$Path)
    
    $Files = Get-ChildItem $Path -Force -ErrorAction SilentlyContinue
    $HasIndicators = $false
    
    foreach ($Indicator in $ProjectIndicators) {
        if ($Files | Where-Object { $_.Name -like $Indicator }) {
            $HasIndicators = $true
            break
        }
    }
    
    # Additional heuristics
    $CodeFiles = $Files | Where-Object { $_.Extension -in @('.py', '.js', '.ts', '.ps1', '.cs', '.java', '.cpp', '.c') }
    $HasMultipleCodeFiles = ($CodeFiles | Measure-Object).Count -ge 2
    
    return $HasIndicators -or $HasMultipleCodeFiles
}

# Function to analyze a project
function Get-ProjectMetadata {
    param([string]$ProjectPath)
    
    Write-Host "Analyzing: $ProjectPath" -ForegroundColor Cyan
    
    $Files = Get-ChildItem $ProjectPath -Recurse -File -ErrorAction SilentlyContinue | 
        Where-Object { $_.Directory.Name -notin $IgnoredPaths }
    
    $CodeFiles = $Files | Where-Object { 
        $_.Extension -in @('.py', '.js', '.ts', '.ps1', '.cs', '.java', '.cpp', '.c', '.html', '.css') 
    }
    
    # Detect project type
    $ProjectType = "Unknown"
    $Technologies = @()
    
    if ($Files | Where-Object { $_.Name -eq "package.json" }) {
        $ProjectType = "Node.js/JavaScript"
        $Technologies += "JavaScript"
        
        # Check package.json for framework info
        try {
            $PackageJson = Get-Content (Join-Path $ProjectPath "package.json") | ConvertFrom-Json
            if ($PackageJson.dependencies.react) { $Technologies += "React" }
            if ($PackageJson.dependencies.vue) { $Technologies += "Vue" }
            if ($PackageJson.dependencies.angular) { $Technologies += "Angular" }
            if ($PackageJson.dependencies.next) { $Technologies += "Next.js" }
            if ($PackageJson.dependencies.express) { $Technologies += "Express" }
        }
        catch { }
    }
    
    if ($Files | Where-Object { $_.Name -eq "requirements.txt" -or $_.Name -eq "setup.py" -or $_.Name -eq "pyproject.toml" }) {
        $ProjectType = "Python"
        $Technologies += "Python"
        
        # Check for common Python frameworks
        $PythonFiles = $CodeFiles | Where-Object { $_.Extension -eq ".py" }
        $AllPythonContent = $PythonFiles | ForEach-Object { Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue }
        $CombinedContent = $AllPythonContent -join " "
        
        if ($CombinedContent -match "from flask|import flask") { $Technologies += "Flask" }
        if ($CombinedContent -match "from django|import django") { $Technologies += "Django" }
        if ($CombinedContent -match "from fastapi|import fastapi") { $Technologies += "FastAPI" }
        if ($CombinedContent -match "import streamlit|import st") { $Technologies += "Streamlit" }
        if ($CombinedContent -match "from langchain|import langchain") { $Technologies += "LangChain" }
    }
    
    if ($Files | Where-Object { $_.Extension -eq ".ps1" }) {
        if ($ProjectType -eq "Unknown") { $ProjectType = "PowerShell" }
        $Technologies += "PowerShell"
    }
    
    if ($Files | Where-Object { $_.Name -like "*.sln" -or $_.Name -like "*.csproj" }) {
        $ProjectType = "C#/.NET"
        $Technologies += "C#", ".NET"
    }
    
    # Get README content for description
    $Description = ""
    $ReadmeFiles = $Files | Where-Object { $_.Name -match "^README" }
    if ($ReadmeFiles) {
        $ReadmeContent = Get-Content $ReadmeFiles[0].FullName -Raw -ErrorAction SilentlyContinue
        if ($ReadmeContent) {
            # Extract first meaningful line as description
            $Lines = $ReadmeContent -split "`n" | Where-Object { $_.Trim() -and $_ -notmatch "^#+ " }
            $Description = ($Lines | Select-Object -First 1).Trim()
            if ($Description.Length -gt 200) {
                $Description = $Description.Substring(0, 200) + "..."
            }
        }
    }
    
    # Calculate project metrics
    $TotalLines = 0
    $TotalFiles = ($CodeFiles | Measure-Object).Count
    
    foreach ($File in $CodeFiles) {
        try {
            $LineCount = (Get-Content $File.FullName | Measure-Object -Line).Lines
            $TotalLines += $LineCount
        }
        catch { }
    }
    
    # Check Git status
    $IsGitRepo = Test-Path (Join-Path $ProjectPath ".git")
    $GitRemote = ""
    if ($IsGitRepo) {
        try {
            Push-Location $ProjectPath
            $GitRemote = git remote get-url origin 2>$null
            Pop-Location
        }
        catch { Pop-Location }
    }
    
    # Check last modified
    $LastModified = ($Files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
    
    return @{
        Name = Split-Path $ProjectPath -Leaf
        Path = $ProjectPath
        Type = $ProjectType
        Technologies = $Technologies
        Description = $Description
        TotalFiles = $TotalFiles
        TotalLines = $TotalLines
        LastModified = $LastModified
        IsGitRepo = $IsGitRepo
        GitRemote = $GitRemote
        SizeKB = [math]::Round(($Files | Measure-Object Length -Sum).Sum / 1KB, 2)
        Languages = ($CodeFiles | Group-Object Extension | Sort-Object Count -Descending | Select-Object -First 3 | ForEach-Object { $_.Name })
        AnalyzedDate = Get-Date
    }
}

# Main execution
Write-Host "=== Project Discovery System ===" -ForegroundColor Cyan
Write-Host "Scanning path: $ScanPath" -ForegroundColor Yellow

# Load existing catalog
$ExistingCatalog = @{}
if (Test-Path $OutputPath) {
    try {
        $ExistingData = Get-Content $OutputPath | ConvertFrom-Json
        foreach ($Project in $ExistingData) {
            $ExistingCatalog[$Project.Path] = $Project
        }
        Write-Host "Loaded existing catalog with $($ExistingData.Count) projects" -ForegroundColor Green
    }
    catch {
        Write-Host "Could not load existing catalog, starting fresh" -ForegroundColor Yellow
    }
}

# Find all potential project directories
Write-Host "Discovering projects..." -ForegroundColor Cyan
$ProjectPaths = @()

Get-ChildItem $ScanPath -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $CurrentPath = $_.FullName
    
    # Skip ignored paths
    $ShouldSkip = $false
    foreach ($IgnoredPath in $IgnoredPaths) {
        if ($CurrentPath -like "*\$IgnoredPath\*" -or $CurrentPath -like "*\$IgnoredPath") {
            $ShouldSkip = $true
            break
        }
    }
    
    if (-not $ShouldSkip -and (Test-IsProject $CurrentPath)) {
        $ProjectPaths += $CurrentPath
    }
}

Write-Host "Found $($ProjectPaths.Count) potential projects" -ForegroundColor Green

# Analyze projects
$ProjectCatalog = @()
$ProcessedCount = 0

foreach ($ProjectPath in $ProjectPaths) {
    $ProcessedCount++
    Write-Progress -Activity "Analyzing Projects" -Status "Processing $ProcessedCount of $($ProjectPaths.Count)" -PercentComplete (($ProcessedCount / $ProjectPaths.Count) * 100)
    
    # Check if we should skip existing projects
    if (-not $UpdateExisting -and $ExistingCatalog.ContainsKey($ProjectPath)) {
        $ProjectCatalog += $ExistingCatalog[$ProjectPath]
        continue
    }
    
    try {
        $Metadata = Get-ProjectMetadata -ProjectPath $ProjectPath
        $ProjectCatalog += $Metadata
        
        # Optional: Auto-analyze with LLM
        if ($AutoAnalyze) {
            Write-Host "Auto-analyzing with LLM: $($Metadata.Name)" -ForegroundColor Cyan
            try {
                & (Join-Path $PSScriptRoot "LM-Assistant.ps1") -ProjectPath $ProjectPath -Action "explain" -ErrorAction SilentlyContinue
            }
            catch {
                Write-Host "LLM analysis failed for $($Metadata.Name)" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "Error analyzing $ProjectPath : $_" -ForegroundColor Red
    }
}

Write-Progress -Activity "Analyzing Projects" -Completed

# Save catalog
Write-Host "Saving project catalog..." -ForegroundColor Cyan
$ProjectCatalog | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutputPath -Encoding UTF8

# Generate summary report
$Summary = @{
    TotalProjects = $ProjectCatalog.Count
    ProjectTypes = $ProjectCatalog | Group-Object Type | Sort-Object Count -Descending
    Technologies = $ProjectCatalog | ForEach-Object { $_.Technologies } | Group-Object | Sort-Object Count -Descending | Select-Object -First 10
    TotalLinesOfCode = ($ProjectCatalog | Measure-Object TotalLines -Sum).Sum
    RecentProjects = $ProjectCatalog | Sort-Object LastModified -Descending | Select-Object -First 5
    LargestProjects = $ProjectCatalog | Sort-Object TotalLines -Descending | Select-Object -First 5
}

# Display summary
Write-Host ""
Write-Host "=== Discovery Summary ===" -ForegroundColor Green
Write-Host "Total Projects Found: $($Summary.TotalProjects)" -ForegroundColor White
Write-Host "Total Lines of Code: $($Summary.TotalLinesOfCode)" -ForegroundColor White
Write-Host ""
Write-Host "Project Types:" -ForegroundColor Cyan
$Summary.ProjectTypes | ForEach-Object { Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White }
Write-Host ""
Write-Host "Top Technologies:" -ForegroundColor Cyan
$Summary.Technologies | ForEach-Object { Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White }
Write-Host ""
Write-Host "Most Recent Projects:" -ForegroundColor Cyan
$Summary.RecentProjects | ForEach-Object { 
    Write-Host "  $($_.Name) ($($_.Type)) - $($_.LastModified.ToString('yyyy-MM-dd'))" -ForegroundColor White 
}

Write-Host ""
Write-Host "✅ Project catalog saved to: $OutputPath" -ForegroundColor Green
Write-Host "✅ Discovery complete!" -ForegroundColor Green

# Suggest next steps
Write-Host ""
Write-Host "💡 Suggested next steps:" -ForegroundColor Cyan
Write-Host "  1. Review the catalog file for project overview" -ForegroundColor White
Write-Host "  2. Use LM-Assistant.ps1 to analyze specific projects" -ForegroundColor White
Write-Host "  3. Run with -AutoAnalyze to get LLM insights on all projects" -ForegroundColor White
Write-Host "  4. Set up regular scans to keep catalog updated" -ForegroundColor White
