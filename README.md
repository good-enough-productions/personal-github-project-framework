# GitHub Project Automation & Context Management System

A comprehensive PowerShell-based automation system for GitHub project management with integrated AI context templates for better collaboration with language models.

## 🎯 System Overview

This system combines traditional project automation with modern AI assistance workflows, providing:

- **Project Creation & Cloning**: Automated GitHub repository setup with templates
- **Context Templates**: Personal profiles for consistent AI collaboration  
- **Template Management**: Organize and manage both code and context templates
- **VS Code Integration**: Seamless development workflow integration

## 📁 Project Structure

```
Active Github Projects/
├── scripts/                          # PowerShell automation scripts
│   ├── Enhanced-Project-Creator.ps1   # Main project creation/cloning tool
│   ├── Template-Manager.ps1           # Code template management
│   ├── Context-Manager.ps1            # AI context template management
│   └── Project-Discovery.ps1          # Scan and catalog existing projects
├── templates/                         # Code project templates
│   ├── python-basic/                  # Python project template
│   ├── powershell-automation/         # PowerShell script template  
│   └── web-app-basic/                 # Basic web application template
├── context-templates/                 # AI context templates
│   ├── personal-profile.md            # Background, goals, learning style
│   ├── tools-and-preferences.md       # Technology stack preferences
│   ├── credentials-and-environment.md # System paths and configuration
│   └── communication-preferences.md   # AI interaction guidelines
└── .vscode/
    └── tasks.json                     # VS Code task definitions
```

## 🚀 Core Tools

### Enhanced-Project-Creator.ps1
**Purpose**: Create new GitHub repositories or clone existing ones with template support

**Key Features**:
- Dual-mode operation: create new projects or clone existing repositories
- Template integration for rapid project setup
- Variable substitution in template files
- Automatic GitHub repository creation
- VS Code workspace setup

**Usage Examples**:
```powershell
# Create a new Python project from template
.\Enhanced-Project-Creator.ps1 -ProjectName "my-ai-tool" -Template "python-basic"

# Clone an existing repository
.\Enhanced-Project-Creator.ps1 -CloneUrl "https://github.com/user/repo.git"

# Interactive mode (prompts for all options)
.\Enhanced-Project-Creator.ps1
```

**Parameters**:
- `-ProjectName`: Name for new project
- `-CloneUrl`: GitHub repository URL to clone
- `-Template`: Template name to use for new projects
- `-Description`: Project description
- `-Private`: Create private repository (switch)
- `-LocalPath`: Custom local path for project

### Template-Manager.ps1  
**Purpose**: Manage code project templates for rapid development setup

**Key Features**:
- List all available templates
- Create new templates from existing projects
- Edit templates in VS Code
- Delete unused templates
- Template validation

**Usage Examples**:
```powershell
# List all templates
.\Template-Manager.ps1 -Action list

# Create new template from current directory
.\Template-Manager.ps1 -Action create -Name "react-app" -Description "React application template"

# Edit existing template
.\Template-Manager.ps1 -Action edit -Name "python-basic"

# Delete template
.\Template-Manager.ps1 -Action delete -Name "old-template"
```

### Context-Manager.ps1
**Purpose**: Manage AI context templates for personalized language model interactions

**Key Features**:
- Combine multiple context templates
- Generate ready-to-use AI chat prompts
- Template editing interface
- Context profile management

**Usage Examples**:
```powershell
# List available context templates
.\Context-Manager.ps1 -Action list

# Create AI chat prompt
.\Context-Manager.ps1 -Action create-prompt -Templates "personal-profile","communication-preferences"

# Combine templates for comprehensive context
.\Context-Manager.ps1 -Action combine -Templates "tools-and-preferences","credentials-and-environment" -OutputFile "project-context.md"

# Edit templates
.\Context-Manager.ps1 -Action update
```

## 🤖 AI Context Templates

### personal-profile.md
Contains your background, technical experience, goals, and learning preferences. Helps AI understand:
- Current skill level and experience
- Learning style and pace preferences  
- Professional background and interests
- Goal-oriented project focus

### tools-and-preferences.md
Documents your technology stack and tool preferences:
- Programming languages and frameworks
- Development tools and IDEs
- Cloud services and platforms
- Decision-making criteria for tool selection

### credentials-and-environment.md
System configuration and development environment details:
- File paths and directory structure
- API keys and service configurations
- Development environment setup
- Project organization standards

### communication-preferences.md
Guidelines for effective AI collaboration:
- Preferred explanation styles
- Code documentation preferences
- Error handling approaches
- Collaboration workflow preferences

## 🔧 Setup & Installation

### Prerequisites
- PowerShell 5.1 or later
- Git installed and configured
- GitHub CLI (`gh`) installed and authenticated
- VS Code (optional, for template editing)

### Initial Setup
1. **Clone or download** this repository to your local machine
2. **Authenticate GitHub CLI**:
   ```powershell
   gh auth login
   ```
3. **Set execution policy** (if needed):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
4. **Customize context templates** with your personal information:
   ```powershell
   .\scripts\Context-Manager.ps1 -Action update
   ```

### VS Code Integration
The system includes VS Code tasks for common operations:

- **Ctrl+Shift+P** → "Tasks: Run Task" → Choose from:
  - "Create New Project" - Run Enhanced-Project-Creator.ps1
  - "Manage Templates" - Run Template-Manager.ps1  
  - "Manage Context" - Run Context-Manager.ps1
  - "Discover Projects" - Scan for existing projects

## 📋 Common Workflows

### Starting a New Project
1. Run `Enhanced-Project-Creator.ps1` with desired template
2. System creates GitHub repo and local workspace
3. Template files are copied and variables substituted
4. VS Code workspace opens ready for development

### Cloning an Existing Project  
1. Run `Enhanced-Project-Creator.ps1` with `-CloneUrl`
2. Repository is cloned to organized local structure
3. Dependencies are detected and documented
4. Development environment is prepared

### Setting Up AI Assistance
1. Use `Context-Manager.ps1` to create personalized AI prompts
2. Combine relevant context templates for your current project
3. Paste generated prompt into AI chat interface
4. AI now understands your preferences and working style

### Managing Templates
1. Create templates from successful project structures
2. Use `Template-Manager.ps1` to organize and maintain templates
3. Regular template updates as your preferences evolve
4. Share templates across different development environments

## 🎛️ Configuration Options

### Template Variables
Templates support variable substitution:
- `{{PROJECT_NAME}}` - Project name
- `{{PROJECT_DESCRIPTION}}` - Project description  
- `{{AUTHOR_NAME}}` - Your name (from git config)
- `{{AUTHOR_EMAIL}}` - Your email (from git config)
- `{{CURRENT_DATE}}` - Current date
- `{{CURRENT_YEAR}}` - Current year

### Environment Customization
- Edit context templates to match your specific setup
- Modify default paths in scripts for your directory structure
- Customize VS Code tasks for your preferred workflow
- Add additional templates for your technology stack

## 🔍 Troubleshooting

### Common Issues

**GitHub CLI Authentication**:
```powershell
# Re-authenticate if commands fail
gh auth logout
gh auth login
```

**PowerShell Execution Policy**:
```powershell
# Enable script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Template Variable Substitution**:
- Ensure template files use correct `{{VARIABLE}}` syntax
- Check that git is configured with user name and email
- Verify template structure matches expected format

**VS Code Integration**:
- Ensure VS Code is in system PATH
- Check that tasks.json is properly formatted
- Restart VS Code after making task configuration changes

### Debug Mode
Most scripts support verbose output for troubleshooting:
```powershell
.\Enhanced-Project-Creator.ps1 -Verbose
```

## 🚀 Future Enhancements

### Planned Features
- **Cloud Integration**: Sync templates across multiple development machines
- **Team Templates**: Shared template repositories for collaborative development
- **Enhanced AI Context**: Project-specific context generation
- **Automation Triggers**: Git hooks for automatic template updates
- **Plugin Architecture**: Extensible system for custom automation scripts

### Contributing
- Add new project templates for different technology stacks
- Enhance existing templates with better practices
- Create specialized context templates for different AI models
- Improve error handling and user experience

## 📚 Resources

### Documentation
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [VS Code Tasks Documentation](https://code.visualstudio.com/docs/editor/tasks)

### Template Examples
- Check the `templates/` directory for working examples
- Context templates provide real-world AI collaboration examples
- VS Code tasks demonstrate automation integration patterns

---

## 📈 System Evolution

This automation system evolved from simple GitHub project creation scripts into a comprehensive development workflow management platform. The addition of AI context templates represents a shift toward AI-assisted development workflows, where consistent context improves collaboration quality with language models.

The system balances traditional automation (project creation, template management) with modern AI assistance patterns (context templates, prompt engineering), creating a unified development experience that leverages both automated workflows and intelligent assistance.

**Last Updated**: December 2024
**Version**: 2.0 - AI Context Integration 
- **Troubleshoot issues:** `.\LM-Assistant.ps1 -Question "How do I fix X?"`
- **Find all projects:** `.\Discover-Projects.ps1 -AutoAnalyze`

## Setup Requirements

### One-Time Setup (You only do this once)

1. **Install Git:**
   - Go to [git-scm.com](https://git-scm.com/)
   - Download and install
   - This is like installing a translator that helps your computer talk to GitHub

2. **Install GitHub CLI:**
   - Open PowerShell as Administrator
   - Type: `winget install --id GitHub.cli`
   - After it installs, type: `gh auth login`
   - Follow the prompts to connect it to your GitHub account
   - This is like giving your computer permission to create repositories for you

3. **Configure the Scripts:**
   - Edit the `New-Project.ps1` file
   - Change the paths to match your computer (instructions inside the file)

## File Structure

```
Active GitHub Projects/
├── 📖 START-HERE.md              # Begin here - quick start guide
├── 🟢 Run-Setup.bat              # One-time setup (run first!)
├── 🔵 Create-New-Project.bat     # Main project creation tool
├── 💬 Save-Conversation.bat      # Archive conversations & context
├── 📚 Documentation/
│   ├── README.md                 # Complete guide (this file)
│   ├── Quick-Reference.md        # Commands & troubleshooting
│   ├── walkthrough-guide.md      # Step-by-step walkthrough
│   └── enhanced-workflow-design.md # Future roadmap & architecture
├── 🗂️ conversations/             # Auto-saved conversation archive
├── 💻 scripts/
│   ├── New-Project.ps1           # Core GitHub automation
│   ├── Setup.ps1                 # Environment configuration
│   ├── Save-Conversation.ps1     # Context preservation
│   ├── LM-Assistant.ps1          # Local LLM integration
│   ├── Discover-Projects.ps1     # Project cataloging system
│   └── tasks.json               # VS Code integration
└── 📊 project-catalog.json       # Auto-generated project database
```

## Troubleshooting

### "Execution Policy" Error
If you get an error about execution policies when running the PowerShell script:
1. Open PowerShell as Administrator
2. Type: `Set-ExecutionPolicy RemoteSigned`
3. Type "Y" when asked

### "Command not found" Errors
This usually means Git or GitHub CLI isn't installed properly. Go back to the setup section.

### Repository Already Exists
If you try to create a repository with a name that already exists on your GitHub account, the script will tell you. Just pick a different name.

## Understanding the Magic

Here's what happens behind the scenes when you run these scripts:

1. **GitHub CLI Creates Repository:** The `gh repo create` command talks to GitHub's servers and creates a new empty repository
2. **Git Clones Locally:** The `git clone` command downloads that empty repository to your computer
3. **VS Code Opens:** The `code .` command tells VS Code to open the project folder

It's like having a robot assistant that does all the boring setup work for you!

## Future Automation Ideas

- **Power Automate Integration:** Connect this to Microsoft Power Automate so you could potentially trigger it from Outlook, Teams, or even your phone
- **n8n Workflows:** Build visual automation workflows that could include additional steps like setting up project templates
- **Conversation Integration:** Automatically create documentation from conversations (like this one!) and add them to new projects
- **Template System:** Pre-configured project structures for different types of work

## Questions or Problems?

Since you're learning, here are some common questions:

**Q: What if I mess something up?**
A: Don't worry! The worst that can happen is you create an empty repository you don't need. You can always delete it from GitHub.com.

**Q: Can I modify these scripts?**
A: Absolutely! They're designed to be customized. Start small - maybe change the default folder location or add your own steps.

**Q: What if I don't understand something?**
A: Each script has comments (lines starting with # in PowerShell) that explain what each part does. Start there!

---

*Remember: The goal is to remove friction from starting new projects so you can focus on the fun stuff - actually building things!*
