# Conversation Auto-Saver Script
# This script helps you save conversations automatically to your project

param(
    [Parameter(Mandatory=$false)]
    [string]$ConversationText,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$Topic = "General Discussion"
)

# Configuration
$BaseProjectsPath = "C:\Users\dschm\OneDrive\Desktop\Active Github Projects"
$ConversationsDir = Join-Path $BaseProjectsPath "conversations"

# Create conversations directory if it doesn't exist
if (!(Test-Path $ConversationsDir)) {
    New-Item -ItemType Directory -Path $ConversationsDir -Force | Out-Null
    Write-Host "Created conversations directory: $ConversationsDir" -ForegroundColor Green
}

# Generate filename with timestamp
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$SafeTopic = ($Topic -replace '[^\w\s-]', '') -replace '\s+', '-'
$Filename = "$Timestamp" + "_$SafeTopic.md"
$FilePath = Join-Path $ConversationsDir $Filename

# If no conversation text provided, prompt for it or use clipboard
if ([string]::IsNullOrWhiteSpace($ConversationText)) {
    Write-Host "No conversation text provided. Checking clipboard..." -ForegroundColor Yellow
    try {
        $ConversationText = Get-Clipboard -Raw
        if ([string]::IsNullOrWhiteSpace($ConversationText)) {
            Write-Host "Clipboard is empty. Please paste your conversation and try again." -ForegroundColor Red
            $ConversationText = Read-Host "Or paste the conversation text here"
        } else {
            Write-Host "Found text in clipboard." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Could not access clipboard. Please provide text manually." -ForegroundColor Yellow
        $ConversationText = Read-Host "Paste the conversation text here"
    }
}

# Build markdown content
$MarkdownContent = @"
# Conversation: $Topic

**Date:** $(Get-Date -Format "MMMM dd, yyyy 'at' h:mm tt")  
**Project:** $($ProjectName -or "General")  
**Topic:** $Topic  

---

$ConversationText
"@

# Save the file
try {
    $MarkdownContent | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host ("Conversation saved to: " + $FilePath) -ForegroundColor Green

    # Open in VS Code if available
    try {
        code $FilePath
        Write-Host 'Opened in VS Code for review' -ForegroundColor Green
    }
    catch {
        Write-Host 'VS Code not available, file saved successfully' -ForegroundColor Cyan
    }

    # Return the file path for potential chaining with other scripts
    return $FilePath
}
catch {
    Write-Host ('Error saving conversation: ' + $_) -ForegroundColor Red
}

# Show instructions for next time
Write-Host ""
Write-Host 'Quick usage tips:' -ForegroundColor Cyan
Write-Host '  - Copy conversation to clipboard, then run this script' -ForegroundColor White
Write-Host '  - Or drag and drop this script to create a desktop shortcut' -ForegroundColor White
Write-Host '  - Use with project creation: .\Save-Conversation.ps1 -Topic "New Feature" -ProjectName "my-project"' -ForegroundColor White
