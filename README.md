# Claude Agents Plus

[![GitHub stars](https://img.shields.io/github/stars/Heroicus/claude-agents-plus?style=social)](https://github.com/Heroicus/claude-agents-plus/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Multi-agent orchestration skill for Claude Code. Automatically intercepts complex tasks and orchestrates 1-6 parallel subagents for execution.

## Demo

<!-- Replace with actual GIF recording -->
```
User: "Build a full-stack auth system with React frontend, Node.js API, and PostgreSQL"

[ASSESSMENT] Complexity: HIGH (score: 9) - 3 domains detected
[ORCHESTRATION] Spawning 3 subagents...
  → Subagent #1: Backend API (implementer)
  → Subagent #2: Frontend (implementer)  
  → Subagent #3: Database (implementer)

[REPORT] 3/3 successful
  ✓ Backend: JWT auth endpoints created
  ✓ Frontend: Login/Register forms built
  ✓ Database: User migration applied
```

## Features

- **Auto-routing hook** — Intercepts every message, assesses complexity
- **Simple task passthrough** — Greetings and simple questions skip orchestration
- **Task decomposition** — Breaks complex tasks into independent subtasks
- **Parallel execution** — Spawns 1-6 implementer subagents
- **Progress tracking** — Uses TaskCreate/TaskUpdate for monitoring
- **Result synthesis** — Collects and merges subagent outputs

## Installation

### Option 1: Clone to skills directory

```bash
git clone https://github.com/Heroicus/claude-agents-plus.git ~/.agents/skills/claude-agents-plus
ln -sf ../../.agents/skills/claude-agents-plus ~/.claude/skills/claude-agents-plus
```

### Option 2: Manual setup

1. Copy `SKILL.md` to `~/.agents/skills/claude-agents-plus/`
2. Create symlink: `ln -sf ../../.agents/skills/claude-agents-plus ~/.claude/skills/claude-agents-plus`
3. Copy hooks to `~/.claude/hooks/`
4. Add hooks to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/agents-plus-router.sh",
            "timeout": 5000
          },
          {
            "type": "command",
            "command": "~/.claude/hooks/agents-plus-activator.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

5. Register in `~/.claude/homunculus/skill-map.json`

## How It Works

```
User Message
    │
    ▼
┌──────────────────────────────────────┐
│ COMPLEXITY ASSESSMENT (Hook)         │
│ Score >= 4? → Trigger orchestration  │
│ Score < 4?  → Pass through           │
└──────────────────────────────────────┘
    │
    ▼ (if complex)
┌──────────────────────────────────────┐
│ TASK DECOMPOSITION                   │
│ Break into independent subtasks      │
└──────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────┐
│ SUBAGENT DISPATCH (1-6 agents)       │
│ Parallel execution via Agent tool    │
└──────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────┐
│ SYNTHESIS & REPORT                   │
│ Collect results, verify, report      │
└──────────────────────────────────────┘
```

## Complexity Triggers

| Signal | Score |
|--------|-------|
| Multi-domain (frontend+backend+DB) | +3 |
| Action verbs (implement/create/build) | +2 |
| Parallel tasks (and/同时/并且) | +2 |
| Large scope (entire/全栈/系统) | +2 |
| Specific patterns (auth/payment/dashboard) | +2 |

Score >= 4 triggers orchestration.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and orchestration protocol |
| `hooks/agents-plus-router.sh` | Complexity assessment hook |
| `hooks/agents-plus-activator.sh` | Skill activation hook |

## Requirements

- Claude Code CLI
- `jq` installed
- Bash shell

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Heroicus/claude-agents-plus&type=Date)](https://star-history.com/#Heroicus/claude-agents-plus&Date)

## License

MIT
