# Credentials & Environment Context Template

## System Configuration

### Development Paths
- **Projects Directory:** `C:\Users\dschm\Documents\GitHub`
- **Active Projects:** `C:\Users\dschm\OneDrive\Desktop\Active Github Projects`
- **Scripts Location:** `[Active Projects]\scripts\`
- **Templates Location:** `[Active Projects]\templates\`

### GitHub Configuration
- **Username:** good-enough-productions
- **Primary Repository Pattern:** Public repositories for tools and automation
- **Branch Strategy:** Main branch for stable code
- **Commit Style:** Descriptive messages with context

### Local Development Setup
- **PowerShell Execution Policy:** RemoteSigned (configured for script execution)
- **Git Configuration:** Integrated with GitHub CLI authentication
- **VS Code Workspace:** Multiple projects in GitHub directory
- **File Organization:** Project-specific folders with consistent structure

## API Keys & Services

### Configured Services
- **GitHub CLI:** Authenticated and configured
- **LM Studio:** Local installation for private LLM access
- **VS Code:** GitHub Copilot extension active

### Environment Variables (Non-sensitive)
- **GITHUB_TOKEN:** (Configured via GitHub CLI)
- **Path Extensions:** Git, GitHub CLI, VS Code command line tools
- **PowerShell Modules:** Custom script locations added to path

### Service Preferences
- **LLM Services:** Local LM Studio > Gemini > ChatGPT/OpenAI
- **Version Control:** GitHub (primary) > Other git services
- **Automation:** Local scripts > Cloud services > SaaS solutions
- **Documentation:** Markdown files > Wiki systems > External docs

## Security Practices

### Data Privacy
- **Sensitive Information:** Keep in local environment variables or config files
- **Repository Content:** Public repos for tools, private for personal/sensitive content
- **LLM Usage:** Prefer local models for sensitive code or personal information
- **Backup Strategy:** Git repositories + OneDrive for documentation

### Access Management
- **GitHub:** Two-factor authentication enabled
- **Local Scripts:** Execution policy configured appropriately
- **File Permissions:** Standard user access, admin when required for installations
- **Network Access:** Local-first approach, minimal external dependencies

## Project Structure Standards

### Repository Organization
```
project-name/
├── README.md              # Project overview and setup
├── main.ps1 or main.py    # Primary executable
├── config/                # Configuration files
├── modules/ or src/       # Helper functions/modules
├── docs/                  # Additional documentation
├── logs/                  # Log files (in .gitignore)
├── .gitignore            # Git ignore rules
└── PROJECT-NOTES.md       # Personal notes and context
```

### Documentation Standards
- **README.md:** Always include purpose, setup, and usage
- **PROJECT-NOTES.md:** Personal context, decisions, future ideas
- **Code Comments:** Explain why, not just what
- **Change Log:** Track major modifications and reasoning

### Naming Conventions
- **Files:** kebab-case for scripts (my-script.ps1)
- **Directories:** lowercase with hyphens (project-templates)
- **Variables:** camelCase in scripts, UPPER_CASE for constants
- **Functions:** Verb-Noun pattern (Get-ProjectInfo, New-Template)

## Integration Points

### VS Code Integration
- **Tasks:** Use tasks.json for common operations
- **Settings:** Workspace-specific configurations
- **Extensions:** Consistent extension set across projects
- **Terminal:** PowerShell as default integrated terminal

### PowerShell Integration
- **Modules:** Shared helper functions across projects
- **Error Handling:** Consistent error handling patterns
- **Logging:** Standardized logging approach
- **Parameters:** Use proper parameter validation

### Git Workflow
- **Commits:** Descriptive messages with context
- **Branches:** Main branch for stable, feature branches for development
- **Tags:** Version releases when appropriate
- **Issues:** GitHub issues for tracking enhancements

---

*Last Updated: {{DATE}}*
*Use this information for environment-specific configurations and file paths.*

**Note:** This file contains system-specific paths and configuration details. 
Update as environment changes or new services are added.
