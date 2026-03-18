# O365 Claude Scripts

Claude Code configuration and toolkit for Office 365 scripting and automation, built on the claude-code-bootstrap template. Includes universal skills for backend/frontend development, TDD, security practices, and specialized agents for planning, error resolution, and architecture review.

## RULE 1 -- Check LL-G Before Scripting (MANDATORY)

**At the start of any session involving scripting, API calls, or automation -- before writing a single line -- fetch the LL-G index and load relevant entries.**

```
Step 1: Fetch https://raw.githubusercontent.com/wellforce-brandon/LL-G/main/llms.txt
Step 2: For each technology you will use, fetch its sub-index (e.g., kb/ninjaone/llms.txt)
Step 3: Read ALL HIGH-severity entries for those technologies
Step 4: Read any MEDIUM entry whose title matches your specific task
```

Technologies currently in LL-G: PowerShell, Graph API, NinjaOne, Next.js, Tailwind CSS, TypeScript, Godot/GDScript, Better Auth, Bash.

This applies to every session, every technician, every developer. Not optional.

### Contributing back

Every plan file MUST end with a **Lessons Learned / Gotchas** section. After implementation, route any new discoveries to LL-G -- not to local agent-memory or local pattern files only.

- Preferred: run `/add-lesson` from any session that has `C:\Github\LL-G` in context
- Manual: create `kb/<tech>/<slug>.md`, update `kb/<tech>/llms.txt`, update the master `llms.txt`

Lessons stored locally stay local. Lessons in LL-G benefit every repo and every technician.

## RULE 3 -- Check BP Before Starting New Work

**When onboarding a repo, starting a new feature, or setting up tooling -- load the BP index and check applicable best practices.**

```
Step 1: Fetch https://raw.githubusercontent.com/wellforce-brandon/BP/main/llms.txt
Step 2: For each concern relevant to your task, read its llms.txt index
Step 3: Load all FOUNDATIONAL entries (these apply to every repo)
Step 4: Load RECOMMENDED entries whose tech tags match the current project
```

BP is the complement to LL-G: where LL-G tracks what NOT to do, BP tracks what TO do.
