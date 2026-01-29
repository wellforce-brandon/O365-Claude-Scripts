# Installation Guide

Step-by-step instructions for setting up O365 Claude Scripts in your project.

## Prerequisites

- Claude Code CLI installed
- Git (for cloning)
- Your project initialized

## Installation Methods

### Method 1: Clone and Copy (Recommended)

```bash
# 1. Clone this template repository
git clone https://github.com/wellforce-brandon/O365-Claude-Scripts.git

# 2. Navigate to your project
cd /path/to/your/project

# 3. Copy .claude folder
cp -r /path/to/O365-Claude-Scripts/.claude ./

# 4. Copy documentation (optional but helpful)
cp -r /path/to/O365-Claude-Scripts/docs ./

# 5. Copy and customize CLAUDE.md
cp /path/to/O365-Claude-Scripts/CLAUDE.md.template ./.claude/CLAUDE.md

# 6. Edit .claude/CLAUDE.md and replace placeholders:
#    - {{PROJECT_NAME}}
#    - {{TECH_STACK}}
#    - {{BACKEND_LANGUAGE}}
#    - etc.

# 7. Copy and rename settings template
cp .claude/settings.local.json.template .claude/settings.local.json

# 8. Make hooks executable (Linux/Mac)
chmod +x .claude/hooks/stop.sh
```

### Method 2: Manual Download

1. **Download ZIP**
   - Go to GitHub repository
   - Click "Code" → "Download ZIP"
   - Extract to temporary location

2. **Copy to Your Project**
   ```bash
   # Copy .claude folder
   cp -r /path/to/extracted/O365-Claude-Scripts/.claude /path/to/your/project/

   # Copy docs (optional)
   cp -r /path/to/extracted/O365-Claude-Scripts/docs /path/to/your/project/
   ```

3. **Customize**
   - Follow steps 5-8 from Method 1 above

### Method 3: GitHub Template (If Available)

1. Click **"Use this template"** button on GitHub
2. Create your repository
3. Clone your new repository
4. Use it as-is or copy to existing project

## Post-Installation Configuration

### 1. Customize CLAUDE.md

Open `.claude/CLAUDE.md` and replace all placeholders:

```markdown
# Replace these placeholders:
{{PROJECT_NAME}}          → Your actual project name
{{PROJECT_DESCRIPTION}}   → Brief description
{{TECH_STACK}}           → Your tech stack summary
{{BACKEND_LANGUAGE}}     → Node.js, Python, Go, Ruby, etc.
{{BACKEND_FRAMEWORK}}    → Express, FastAPI, Gin, Rails, etc.
{{DATABASE}}             → PostgreSQL, MySQL, MongoDB, etc.
{{FRONTEND_FRAMEWORK}}   → Next.js, React, Vue, Angular, etc.
{{UI_LIBRARY}}           → Material UI, Tailwind, Bootstrap, etc.
{{NAMING_CONVENTIONS}}   → Your naming rules
{{FILE_ORGANIZATION}}    → Your file structure rules
```

### 2. Customize Skills for Your Stack

#### For Python Projects

Edit `.claude/skills/core/backend-dev-guidelines.md`:
- Update examples to use FastAPI/Django patterns
- Replace `pool.query` with `asyncpg` or `psycopg2` examples
- Update error handling for Python

Edit `.claude/skills/core/tdd-workflow.md`:
- Replace Jest examples with pytest examples

#### For Go Projects

Use `.claude/skills/optional/go-desktop-agent-guidelines.md` as reference.

Edit `.claude/skills/core/backend-dev-guidelines.md`:
- Update examples to use Go patterns
- Use `database/sql` instead of pool.query
- Follow Go conventions

#### For Ruby Projects

Edit `.claude/skills/core/backend-dev-guidelines.md`:
- Update examples to use Rails patterns
- Use ActiveRecord examples
- Follow Rails conventions

### 3. Update skill-rules.json (Optional)

Edit `.claude/skill-rules.json` to add project-specific triggers:

```json
{
  "backend-dev-guidelines": {
    "promptTriggers": {
      "keywords": [
        "backend",
        "api",
        "your-framework-name"  // Add your framework
      ]
    }
  }
}
```

### 4. Test the Setup

```bash
# Start Claude Code
claude-code

# Test skill activation
# Type: "Create an API endpoint"
# Skills should auto-suggest

# Test commands
# Type: /dev-docs
# Should create a planning document
```

## Verify Installation

### Check File Structure

```bash
your-project/
├── .claude/
│   ├── agents/              # ✅ 4 agent files
│   ├── skills/
│   │   ├── core/           # ✅ 7 core skills
│   │   └── optional/       # ✅ 4 optional skills
│   ├── commands/           # ✅ 5 command files
│   ├── hooks/              # ✅ Hook files + utils/
│   ├── CLAUDE.md           # ✅ Customized (not .template)
│   ├── settings.local.json # ✅ (not .template)
│   └── skill-rules.json    # ✅
└── docs/                   # ✅ (optional) 10 documentation files
```

### Verify Hooks are Executable

```bash
# Linux/Mac
ls -la .claude/hooks/stop.sh
# Should show: -rwxr-xr-x (x means executable)

# If not executable:
chmod +x .claude/hooks/stop.sh
```

### Test Auto-Activation

1. **Test Backend Skill**
   - Type: "Create a new API endpoint"
   - Should suggest: `backend-dev-guidelines`

2. **Test Frontend Skill**
   - Type: "Create a new React component"
   - Should suggest: `frontend-dev-guidelines`

3. **Test Security Skill**
   - Type: "Implement user authentication"
   - Should suggest: `security-practices`

4. **Test MVP Principles**
   - Type: "Let's refactor this to use a service layer"
   - Should suggest: `production-principles`

## Troubleshooting

### Skills Not Activating

**Problem**: Skills don't auto-suggest

**Solutions**:
1. Check `.claude/skill-rules.json` exists
2. Verify `CLAUDE.md` is named correctly (not `.template`)
3. Try explicit activation: "Use backend-dev-guidelines skill"
4. Restart Claude Code session

### Hooks Not Running

**Problem**: Hooks don't execute

**Solutions**:
1. Check `.claude/settings.local.json` exists (not `.template`)
2. Verify paths in settings.local.json are correct
3. Make `stop.sh` executable: `chmod +x .claude/hooks/stop.sh`
4. Check hook file permissions
5. Restart Claude Code

### Commands Not Working

**Problem**: Slash commands don't work

**Solutions**:
1. Check `.claude/commands/` folder has `.md` files
2. Restart Claude Code session
3. Type `/` to see available commands
4. Verify command file format is correct

### Wrong Tech Stack Examples

**Problem**: Skills show Node.js but I use Python

**Solutions**:
1. Customize skill files in `.claude/skills/core/`
2. Update code examples for your stack
3. See "Stack Adapters" in each skill file
4. Check `docs/01-CLAUDE-CODE-SETUP.md` for examples

## Next Steps

1. **Read Quick Start**
   - `docs/00-QUICK-START.md`

2. **See Full Example**
   - `docs/10-COMPLETE-EXAMPLE.md`

3. **Build First Feature**
   - Use `/dev-docs` to plan
   - Let skills guide you
   - Watch the magic happen!

4. **Customize Further**
   - Add project-specific skills
   - Create custom agents
   - Tailor to your workflow

## Support

- **Documentation**: See `docs/` folder
- **Questions**: Check `docs/INDEX.md` for navigation
- **Issues**: Report on GitHub repository

---

**Installation Time**: 15-30 minutes
**First Value**: Immediate (next feature you build)
**ROI**: 10x within first week

Happy shipping! 🚀
