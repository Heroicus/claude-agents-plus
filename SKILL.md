---
name: claude-agents-plus
description: >
  Multi-agent orchestration workflow. Intercepts user messages, assesses complexity,
  and routes simple tasks directly while orchestrating 1-6 parallel subagents for complex tasks.
  The main agent decomposes tasks, dispatches to subagents, collects results, and reports back.
  Use when the user says "agents plus", "multi-agent", "parallel agents", "spawn agents",
  or when a task involves multiple domains (frontend + backend + database, research + implementation, etc.).
allowed-tools: Agent, TaskCreate, TaskUpdate, TaskList, TaskGet, TaskOutput, Skill
---

# Claude Agents Plus — Multi-Agent Orchestration

## MANDATORY EXECUTION PROTOCOL

**When this skill is activated, you MUST follow this protocol exactly:**

1. **DO NOT** handle the task yourself — you are the orchestrator, not the implementer
2. **DO** decompose the task into subtasks before any action
3. **DO** create TaskCreate entries for progress tracking
4. **DO** spawn subagents for each independent subtask
5. **DO** collect and synthesize results before reporting to user

**Violation of this protocol defeats the purpose of multi-agent orchestration.**

## Core Workflow

```
User Message
    │
    ▼
┌──────────────────────────────────────┐
│ 1. COMPLEXITY ASSESSMENT             │
│    Is this a simple task?            │
└──────────────────────────────────────┘
    │
    ├─ YES (simple) ──▶ Handle directly, skip orchestration
    │
    └─ NO (complex) ──▶ Continue to orchestration
                            │
                            ▼
                ┌──────────────────────────────────────┐
                │ 2. TASK DECOMPOSITION                 │
                │    Break into independent subtasks    │
                │    Identify required skills           │
                └──────────────────────────────────────┘
                            │
                            ▼
                ┌──────────────────────────────────────┐
                │ 3. SUBAGENT DISPATCH                  │
                │    Spawn 1-6 subagents                │
                │    Each gets clear mandate            │
                └──────────────────────────────────────┘
                            │
                            ▼
                ┌──────────────────────────────────────┐
                │ 4. EXECUTION & COLLECTION             │
                │    Subagents work in parallel         │
                │    Main agent monitors progress       │
                └──────────────────────────────────────┘
                            │
                            ▼
                ┌──────────────────────────────────────┐
                │ 5. SYNTHESIS & REPORT                 │
                │    Merge results                      │
                │    Verify consistency                 │
                │    Report to user                     │
                └──────────────────────────────────────┘
```

## Phase 1: Complexity Assessment

### Simple Task Criteria (handle directly)

- Single-file edit or fix
- Grep/search/find operation
- Quick question or explanation
- Greeting or identity query
- Simple config change
- Reading/explaining code
- One clear action item

### Complex Task Criteria (trigger orchestration)

- **Multi-domain**: involves 2+ of: frontend, backend, database, devops, testing
- **Multi-file**: requires coordinated changes across 3+ files
- **Multi-step**: has sequential dependencies (A then B then C)
- **Parallelizable**: contains independent workstreams
- **Research + Implementation**: needs investigation before coding
- **Large scope**: new feature, refactor, migration, architecture change

### Assessment Output

```
[ASSESSMENT]
Task: <brief description>
Complexity: SIMPLE | COMPLEX
Reason: <why>
Domains: <list if complex>
Subtask count estimate: <1-6 if complex>
[/ASSESSMENT]
```

## Phase 2: Task Decomposition

For complex tasks, decompose into independent subtasks:

### Decomposition Rules

1. **Maximize independence**: Each subtask should be executable without waiting for others
2. **Minimize coupling**: Shared state between subtasks should be minimal
3. **Clear boundaries**: Each subtask has defined inputs/outputs
4. **Right-sized**: Each subtask completable by one agent in reasonable time

### Subtask Template

```
[SUBTASK #N]
Title: <descriptive name>
Domain: <frontend|backend|database|devops|testing|research>
Dependencies: <none | list of subtask numbers>
Skills: <which skills this subagent needs>
Scope: <specific files, functions, or areas>
Deliverable: <what this subagent produces>
[/SUBTASK #N]
```

### Skill Selection

Based on subtask domain, activate relevant skills:

| Domain | Skills to Activate |
|--------|-------------------|
| Frontend | senior-frontend, ui-design-system |
| Backend | senior-backend, api-design-reviewer |
| Database | sql-database-assistant, database-designer |
| Testing | tdd-guide, playwright-pro |
| DevOps | senior-devops, ci-cd-pipeline-builder |
| Security | security-review, senior-secops |
| Full-stack | senior-fullstack |
| Research | research-summarizer |

## Phase 3: Subagent Dispatch

### Subagent Count Decision

| Scenario | Count | Rationale |
|----------|-------|-----------|
| 2-3 independent workstreams | 2-3 | Natural parallelism |
| Frontend + Backend + DB | 3 | One per layer |
| Large refactor (multiple modules) | 4-5 | One per module area |
| Complex feature (many concerns) | 5-6 | Maximum parallelism |
| Sequential dependencies | 1-2 | Limited parallelism |

### Dispatch Protocol

For each subtask, spawn a subagent with:

```
Agent(subagent_type: "implementer", prompt: """
You are Subagent #N in a multi-agent orchestration.

YOUR TASK: <subtask title>
SCOPE: <specific files/areas to modify>
CONSTRAINTS:
- Only modify files in your scope
- Follow existing code patterns
- Do not introduce new dependencies without approval
- Output format: <expected deliverable>

CONTEXT:
<relevant background from main agent>

INSTRUCTIONS:
<step-by-step what to do>
""")
```

### Main Agent Responsibilities During Dispatch

1. **Track all subagent IDs** for status monitoring
2. **Provide necessary context** to each subagent
3. **Set clear boundaries** (what each can/cannot touch)
4. **Define output format** for consistent collection

## Phase 4: Execution & Collection

### Parallel Execution

- All independent subagents run simultaneously
- Dependent subagents wait for prerequisites
- Main agent does NOT do implementation work during this phase

### Progress Monitoring

**Implementation with TaskCreate/TaskOutput:**

1. **Create tasks before spawning:**
   ```
   TaskCreate(subject: "Subtask 1: Backend API", description: "...")
   TaskCreate(subject: "Subtask 2: Frontend", description: "...")
   ```

2. **Mark in-progress when spawning:**
   ```
   TaskUpdate(taskId: "1", status: "in_progress")
   ```

3. **Spawn subagents with run_in_background:**
   ```
   Agent(subagent_type: "implementer", run_in_background: true, prompt: "...")
   ```

4. **Check status non-blocking:**
   ```
   TaskList()  // See all tasks
   TaskGet(taskId: "1")  // Check specific task
   ```

5. **Mark completed when done:**
   ```
   TaskUpdate(taskId: "1", status: "completed")
   ```

**Monitoring Rules:**
- Do NOT busy-wait or poll excessively
- Check status after reasonable intervals
- If subagent returns, process immediately
- If subagent hangs, timeout and retry

### Failure Handling

If a subagent fails:
1. Log the error
2. Assess impact on other subtasks
3. Either:
   - Retry with adjusted prompt
   - Reassign to another subagent
   - Simplify the subtask
   - Report partial completion to user

## Phase 5: Synthesis & Report

### Result Collection

Collect from each completed subagent:
- What was changed (files, functions)
- Key decisions made
- Any warnings or issues
- Test results if applicable

### Consistency Verification

Check for:
- No conflicting changes between subagents
- Imports/references are consistent
- Naming conventions align
- No duplicate code introduced

### Final Report

```
[ORCHESTRATION REPORT]
Task: <original task>
Subagents: <N> spawned, <M> successful

Summary:
<what was accomplished>

Changes:
1. <file/component>: <what changed>
2. <file/component>: <what changed>
...

Decisions:
- <key decision 1>: <rationale>
- <key decision 2>: <rationale>

Warnings:
- <any issues or caveats>

Next Steps:
- <suggested follow-up actions>
[/ORCHESTRATION REPORT]
```

## Execution Model

This skill orchestrates via Claude Code's Agent tool:

### Main Agent Behavior

1. **Assess complexity** — analyze user message
2. **If simple**: handle directly, no orchestration overhead
3. **If complex**:
   a. Decompose into subtasks
   b. Create TaskCreate entries for tracking
   c. For each subtask, spawn Agent with:
      - `subagent_type: "implementer"` (has Read/Write/Edit/Grep/Glob/Bash)
      - Clear, self-contained prompt
      - Scope restrictions
   d. Collect results via TaskOutput or Agent returns
   e. Synthesize and report

### Subagent Types Available

| Type | Best For |
|------|----------|
| implementer | Code changes, file modifications |
| researcher | Read-only investigation, no writes |
| code-reviewer | Reviewing changes for issues |
| test-runner | Running and validating tests |
| architect | Design decisions, no implementation |

### Key Constraints

- **Max 6 subagents** — beyond this, context and coordination overhead outweighs parallelism benefits
- **Min 1 subagent** — even "simple complex" tasks benefit from isolated execution
- **Subagents are isolated** — each starts fresh, no shared memory
- **Main agent synthesizes** — subagents don't communicate directly

## Dependency Handling

### Dependency Types

| Type | Description | Strategy |
|------|-------------|----------|
| **None** | Fully independent | Spawn all in parallel |
| **Sequential** | A → B → C | Spawn in order, wait for each |
| **Data** | B needs A's output | Spawn A first, pass output to B |
| **Shared** | A and B share resources | Coordinate via main agent |

### Dependency Resolution Protocol

1. **Identify dependencies** during decomposition
2. **Build dependency graph** (simple: list, complex: DAG)
3. **Execution order**:
   - Independent tasks: parallel spawn
   - Dependent tasks: sequential spawn
   - Data dependencies: spawn producer first, collect output, pass to consumer
4. **Main agent mediates** all inter-subtask communication

### Example: Sequential Dependencies

```
Subtask 1: Database schema (no deps) → spawn first
Subtask 2: Backend API (depends on 1) → wait for 1, then spawn
Subtask 3: Frontend (depends on 2) → wait for 2, then spawn
```

### Example: Data Dependencies

```
Subtask 1: Research existing patterns → spawn, collect findings
Subtask 2: Implement based on research → spawn with findings as context
```

## Skill Auto-Activation

When orchestrating, activate relevant skills for each subtask:

### Activation Protocol

1. **Before spawning subagent**, activate required skills:
   ```
   Skill(skill: "senior-frontend")  // if frontend work
   Skill(skill: "sql-database-assistant")  // if database work
   ```

2. **Include skill context** in subagent prompt:
   ```
   The following skills are active for this task:
   - senior-frontend: Use React/Next.js patterns
   - tdd-guide: Write tests first
   ```

3. **Skill selection table** (reference):

| Subtask Domain | Skills to Activate |
|----------------|-------------------|
| Frontend | senior-frontend, ui-design-system |
| Backend | senior-backend, api-design-reviewer |
| Database | sql-database-assistant, database-designer |
| Testing | tdd-guide, playwright-pro |
| DevOps | senior-devops, ci-cd-pipeline-builder |
| Security | security-review, senior-secops |
| Full-stack | senior-fullstack |
| Research | research-summarizer |

## Example Orchestration

**User**: "Add user authentication with JWT, including login/register API endpoints, frontend forms, and database migrations"

**Assessment**:
```
[ASSESSMENT]
Task: Add JWT auth with API + frontend + DB
Complexity: COMPLEX
Reason: 3 domains (backend, frontend, database), 4+ files
Domains: backend, frontend, database
Subtask count estimate: 3
[/ASSESSMENT]
```

**Decomposition**:
- Subtask 1: Backend API (auth endpoints, JWT logic)
- Subtask 2: Frontend (login/register forms, auth state)
- Subtask 3: Database (user table migration, schema)

**Dispatch**: 3 subagents, one per layer

**Synthesis**: Merge results, verify API-frontend contract, check migration applies cleanly

## Anti-Patterns

- **Over-orchestration**: Don't spawn agents for simple tasks
- **Under-scoping**: Each subagent needs enough context to work independently
- **Coupled subtasks**: If subtask B needs subtask A's exact output, they're not parallel
- **Too many subagents**: >6 creates coordination chaos
- **Main agent doing work**: During dispatch phase, main agent orchestrates only
