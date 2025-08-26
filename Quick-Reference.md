# Quick Reference Guide

## What Each File Does

### 📁 **scripts/Enhanced-Project-Creator.ps1** ⭐ MAIN TOOL
**What it is:** Advanced project creator with templates and cloning  
**What it does:** Creates new repos OR clones existing ones, with template support  
**How to use:** `.\Enhanced-Project-Creator.ps1` or VS Code tasks  
**Features:** Clone existing repos, project templates, variable substitution, smart setup
**Parameters:** `-CloneUrl`, `-ProjectName`, `-Template`, `-Description`, `-Private`

### 📁 **scripts/Template-Manager.ps1** ⭐ CODE TEMPLATES
**What it is:** Code template management system  
**What it does:** Create, edit, and manage project templates  
**How to use:** `.\Template-Manager.ps1` (see usage examples below)  
**Features:** List templates, create new ones, edit existing templates  

### 📁 **scripts/Context-Manager.ps1** ⭐ AI TEMPLATES  
**What it is:** AI context template management system  
**What it does:** Manage personal profiles for better AI collaboration  
**How to use:** `.\Context-Manager.ps1 -Action [list|create-prompt|combine|update]`  
**Features:** Generate AI chat prompts, combine context profiles, edit templates

### 📁 **Quick-Start.ps1** ⭐ SETUP HELPER
**What it is:** Interactive setup and feature guide  
**What it does:** Checks prerequisites and guides you through available tools  
**How to use:** `.\Quick-Start.ps1` - Interactive menu system  
**Features:** Prerequisites check, feature demos, guided setup  

### 📁 **context-templates/** ⭐ AI CONTEXT PROFILES
**What it is:** Personal profiles for AI collaboration  
**Contains:** personal-profile.md, tools-and-preferences.md, credentials-and-environment.md, communication-preferences.md  
**Purpose:** Help AI understand your background, skills, and preferences  
**How to use:** Context-Manager.ps1 creates prompts from these profiles  

### 📁 **templates/** ⭐ CODE PROJECT TEMPLATES  
**What it is:** Code scaffolding templates for rapid project setup  
**Contains:** python-basic/, powershell-automation/, web-app-basic/  
**Purpose:** Starter code and project structure for different project types  
**How to use:** Enhanced-Project-Creator.ps1 uses these when creating new projects  

### 📁 **.vscode/tasks.json**
**What it is:** VS Code integration file  
**What it does:** Adds GitHub automation to VS Code's task menu  
**How to use:** Automatically works when you open this workspace in VS Code  
**How to access:** In VS Code: Ctrl+Shift+P → "Tasks: Run Task"  

## Quick Start (Do This First!)

1. **Run Quick Start:** `.\Quick-Start.ps1` - Interactive setup and feature guide
2. **Set up AI context:** Use Context-Manager.ps1 to create your AI profiles  
3. **Test project creation:** Use Enhanced-Project-Creator.ps1 to create a test project
4. **Try cloning:** Use Enhanced-Project-Creator.ps1 to clone an existing repo

## Core Features

### 🚀 Project Creation & Cloning
- **Enhanced-Project-Creator.ps1** - Main automation tool
- **Create new projects** with templates and smart setup
- **Clone existing repositories** with organized structure  
- **VS Code integration** for seamless workflow

### 🤖 AI Context Management  
- **Context-Manager.ps1** - Manage AI collaboration profiles
- **Create chat prompts** with your personal context
- **Combine templates** for project-specific context
- **Update profiles** as your skills evolve

### 🎨 Template Management
- **Template-Manager.ps1** - Manage code project templates
- **Code templates** for rapid project setup
- **AI context templates** for consistent AI collaboration
- **Custom variables** and intelligent substitution

## Common Usage Examples

### 🎯 Enhanced Project Creator
```powershell
# Interactive mode (recommended for first time)
.\scripts\Enhanced-Project-Creator.ps1

# Clone with custom name
.\scripts\Enhanced-Project-Creator.ps1 -CloneUrl "https://github.com/user/repo.git" -ProjectName "my-custom-name"

# Create new project with template
.\scripts\Enhanced-Project-Creator.ps1 -ProjectName "my-app" -Template "python-basic" -Description "My Python project"

# Create private repository
.\scripts\Enhanced-Project-Creator.ps1 -ProjectName "secret-project" -Private -Description "Private project"
```

### 🤖 AI Context Management
```powershell
# List available context templates
.\scripts\Context-Manager.ps1 -Action list

# Create AI chat prompt (copies to clipboard!)
.\scripts\Context-Manager.ps1 -Action create-prompt

# Create prompt with specific templates
.\scripts\Context-Manager.ps1 -Action create-prompt -Templates "personal-profile","tools-and-preferences"

# Combine templates for project documentation
.\scripts\Context-Manager.ps1 -Action combine -Templates "tools-and-preferences","credentials-and-environment" -OutputFile "project-context.md"

# Edit your context templates
.\scripts\Context-Manager.ps1 -Action update
```

### 🎨 Template Management  
```powershell
# List all available code templates
.\scripts\Template-Manager.ps1 -Action list

# Create new template from current directory
.\scripts\Template-Manager.ps1 -Action create -Name "react-app" -Description "React application template"

# Edit existing template
.\scripts\Template-Manager.ps1 -Action edit -Name "python-basic"

# Get template information
.\scripts\Template-Manager.ps1 -Action info -Name "web-app-basic"

# Delete unused template
.\scripts\Template-Manager.ps1 -Action delete -Name "old-template"
```

### 🔧 VS Code Integration
Available tasks (Ctrl+Shift+P → "Tasks: Run Task"):
- **Create New Project** - Interactive project creation
- **Clone Repository** - Clone with custom naming
- **Manage Code Templates** - Template management interface
- **Manage AI Context Templates** - Context template management
- **Create AI Chat Prompt** - Generate AI prompts
- **Update Context Templates** - Edit your AI profiles
- **Discover Projects** - Scan and catalog existing projects
- **Quick Start Guide** - Interactive setup helper

## Troubleshooting Quick Fixes

### ❌ "Cannot be loaded because running scripts is disabled"
**Fix:** Run PowerShell as Administrator, type: `Set-ExecutionPolicy RemoteSigned`

### ❌ "The term 'gh' is not recognized"
**Fix:** Install GitHub CLI: `winget install --id GitHub.cli`

### ❌ "The term 'git' is not recognized"  
**Fix:** Install Git from git-scm.com or run: `winget install --id Git.Git`

### ❌ "Repository already exists"
**Fix:** Choose a different repository name or delete the existing one

### ❌ "A parameter cannot be found that matches parameter name 'replace'"
**Fix:** This was a bug in earlier versions - update to the latest Enhanced-Project-Creator.ps1

### ❌ Script opens and closes immediately
**Fix:** Right-click the .ps1 file → "Run with PowerShell" instead of double-clicking

### ❌ "Failed to clone repository"
**Solutions:**
- Check your internet connection
- Verify the repository URL is correct and accessible
- Make sure you have permission to access the repository
- Try running `gh auth login` to re-authenticate

### ❌ VS Code doesn't open automatically
**Solutions:**
- Make sure VS Code is installed and in your system PATH
- Try running `code --version` in PowerShell to test
- Install VS Code from: https://code.visualstudio.com/

## System Requirements & Setup

### Prerequisites Checklist
- ✅ Windows 10/11 with PowerShell 5.1+
- ✅ Git installed and configured (`git --version`)
- ✅ GitHub CLI installed (`gh --version`)  
- ✅ GitHub CLI authenticated (`gh auth status`)
- ✅ VS Code installed (optional, for editing)

### Quick Health Check
Run this command to check your setup:
```powershell
.\Quick-Start.ps1
```

This will verify all prerequisites and guide you through any missing components.

## Advanced Features Deep Dive

### 🤖 AI Context Templates - Game Changer Feature
This is what makes your system unique! Instead of starting every AI conversation from scratch, you can now:

**Create AI Profiles:**
- `personal-profile.md` - Your background, skills, learning style
- `tools-and-preferences.md` - Your preferred tech stack and tools  
- `credentials-and-environment.md` - Your system setup and paths
- `communication-preferences.md` - How you like AI to communicate with you

**Generate Smart Prompts:**
```powershell
# Creates a comprehensive prompt and copies to clipboard
.\scripts\Context-Manager.ps1 -Action create-prompt
```
Then paste into ChatGPT, Claude, Gemini, etc. - they'll instantly understand:
- Your current skill level
- What tools you prefer
- How you like explanations
- Your current projects and goals

**Real Impact:** Instead of "help me with Python" you get responses tailored to your experience level, preferred libraries, and coding style!

### 🔄 Workflow Integration
**Daily Development Workflow:**
1. **Start project:** Enhanced-Project-Creator.ps1 (create or clone)
2. **Get AI help:** Context-Manager.ps1 creates smart prompts
3. **AI understands you:** No need to re-explain your preferences
4. **Build with confidence:** Templates and automation handle setup

**Project Types Supported:**
- Python applications (with template)
- PowerShell automation scripts (with template)
- Web applications (with template)
- Any repository you can clone and customize

### 🚀 Power User Tips

**Template Variables:** Your code templates support smart substitution:
- `{{PROJECT_NAME}}` - Becomes your project name
- `{{PROJECT_DESCRIPTION}}` - Your project description
- `{{AUTHOR_NAME}}` - Your name from git config
- `{{CURRENT_DATE}}` - Today's date
- `{{GITHUB_USERNAME}}` - Your GitHub username

**AI Context Combinations:**
```powershell
# For learning new technology
-Templates "personal-profile","communication-preferences"

# For project work  
-Templates "tools-and-preferences","credentials-and-environment"

# For comprehensive help
-Templates "personal-profile","tools-and-preferences","communication-preferences"
```

**VS Code Power Features:**
- All tools integrated as tasks (Ctrl+Shift+P)
- Context templates open directly in editor
- Project creation opens new workspace automatically

## Next Level Customization

### Customize Default Paths
Edit the Enhanced-Project-Creator.ps1 configuration section:
```powershell
# Change this to your preferred location
$ProjectsDirectory = "C:\Users\dschm\Documents\GitHub"

# Update with your GitHub username
$GitHubUsername = "your-username"
```

### Add Your Own Templates
Create new project templates:
```powershell
.\scripts\Template-Manager.ps1 -Action create -Name "my-template" -Description "My custom template"
```

### Personalize AI Context
Edit your context templates to match your real preferences:
```powershell
.\scripts\Context-Manager.ps1 -Action update
```

### Team Sharing
- Share the `templates/` folder for consistent project setup
- Share specific context templates for team AI collaboration standards
- Export combined context for project-specific requirements

## Understanding the System Evolution

**What Started:** Simple GitHub project creation scripts
**What It Became:** Complete AI-assisted development workflow platform

**Key Innovation:** Context templates bridge the gap between traditional automation and modern AI collaboration, creating consistent, personalized development experiences.

**Future Possibilities:**
- Cloud sync for templates across machines
- Team collaboration features
- Project-specific AI context generation
- Integration with more development tools

This system recognizes that modern development increasingly involves AI assistance, so it provides the infrastructure to make that collaboration more effective and consistent! 🚀
