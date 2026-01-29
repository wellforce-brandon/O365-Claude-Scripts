# O365 Claude Scripts

**Claude Code configuration for Office 365 scripting and automation.**

Built on the [Claude Code Bootstrap](https://github.com/wellforce-brandon/claude-code-bootstrap) template. Framework-agnostic configuration for 10x faster development with Claude Code.

---

## Quick Start

1. **Copy CLAUDE.md.template** to `.claude/CLAUDE.md`
2. **Customize placeholders** for your O365 project
3. **Start developing** with Claude Code

See `docs/00-QUICK-START.md` for detailed setup instructions.

## What's Included

### Core Skills (7 universal)
- **backend-dev-guidelines** - Direct SQL, simple APIs, production-ready from start
- **frontend-dev-guidelines** - Simple components, direct API calls, UIC system
- **production-principles** - YAGNI, Rule of Three, Simple > Complex
- **tdd-workflow** - Red-Green-Refactor, tests first
- **UIC_Guidelines** - Universal ID Convention for 10x faster debugging
- **security-practices** - Authentication, SQL injection prevention, password hashing
- **skill-developer** - Guide for creating custom skills

### Optional Skills (4 specialized)
- **go-desktop-agent-guidelines** - Go + Wails desktop development
- **openai-api-expert** - GPT-5 Mini integration and best practices
- **prompt-engineering-expert** - AI prompt design and optimization
- **rest-api-expert** - REST API design patterns

### Core Agents (4 automation workers)
- **strategic-plan-architect** - Create detailed implementation plans
- **build-error-resolver** - Fix TypeScript/compilation errors systematically
- **code-architecture-reviewer** - Review code against best practices
- **production-principles-enforcer** - Prevent over-engineering before it starts

### Commands (5 workflow shortcuts)
- `/dev-docs` - Create strategic implementation plan
- `/dev-docs-update` - Update plan with progress
- `/build-and-fix` - Run build and fix all errors
- `/code-review` - Architecture review
- `/test-api` - Test API endpoints

### Hooks (automation)
- **user-prompt-submit.ts** - Skill suggestion, context analysis
- **stop.sh/.bat** - Auto-format, build check, error detection
- **utils/** - Build checker, error pattern detection, file tracking

### Documentation (10 comprehensive guides)
- **README.md** - Overview and navigation
- **00-QUICK-START.md** - 5-minute setup
- **01-CLAUDE-CODE-SETUP.md** - Complete configuration guide
- **02-UIC-SYSTEM.md** - Universal ID Convention
- **03-MVP-PRINCIPLES.md** - Development philosophy
- **04-SKILLS-SYSTEM.md** - Auto-activating guidelines
- **05-AGENTS-SYSTEM.md** - Specialized AI workers
- **06-HOOKS-AUTOMATION.md** - Automation system
- **07-NEW-PROJECT-CHECKLIST.md** - Step-by-step setup
- **10-COMPLETE-EXAMPLE.md** - Real-world walkthrough

## Installation

```bash
# Clone this repository
git clone https://github.com/wellforce-brandon/O365-Claude-Scripts.git

# Copy to your project
cp -r O365-Claude-Scripts/.claude /path/to/your/project/
cp -r O365-Claude-Scripts/docs /path/to/your/project/

# Follow setup guide
# See docs/00-QUICK-START.md
```

## Documentation

Start here based on your goal:

### "I Want to Ship Fast" (30 minutes)
1. Read `docs/00-QUICK-START.md`
2. Copy `.claude` folder
3. Read `docs/10-COMPLETE-EXAMPLE.md`
4. Start building!

### "I Want to Understand Everything" (3 hours)
1. Read all documentation in `docs/` folder
2. Customize for your stack
3. Follow `docs/07-NEW-PROJECT-CHECKLIST.md`

## Key Features

### 1. Skills Auto-Activation
Skills activate automatically based on your prompts:
- Type "backend" -> Backend guidelines activate
- Type "component" -> Frontend + UIC guidelines activate
- Type "refactor" -> MVP principles enforce simplicity

### 2. UIC System (Universal ID Convention)
Debugging made 10x faster:
- Before: "The submit button is broken" (which one?)
- After: "LOGBUT0001 is broken" (found in 5 seconds!)

### 3. MVP Principles
Ship 10x faster by avoiding over-engineering:
- YAGNI (You Aren't Gonna Need It)
- Rule of Three (extract after 3rd duplicate)
- Simple > Complex (always)

### 4. TDD Workflow
Higher quality with fewer bugs:
- Red-Green-Refactor cycle
- Tests first, implementation second
- Near-zero production bugs

### 5. Hooks Automation
Zero manual cleanup:
- Code formatted automatically
- Build checked after changes
- Errors detected before commit

## License

MIT License - See [LICENSE](LICENSE) for details.

## Acknowledgments

Based on [claude-code-bootstrap](https://github.com/wellforce-brandon/claude-code-bootstrap) - battle-tested on real production applications.

---

**Time to first value**: 5 minutes
**Time to mastery**: 1 week
**ROI**: 10x faster development with fewer bugs
