#!/bin/bash
# Claude Agents Plus - Skill Activator
# Ensures claude-agents-plus skill is properly activated when complexity is detected

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Check if agents-plus-router already detected complexity
# This hook runs after agents-plus-router, so we check for its output
# The router hook outputs [SKILL_ROUTE] marker to stdout

# We need to force-activate the skill by emitting hookSpecificOutput
# This ensures the skill-auto-activate rules process it correctly

PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')
CHAR_COUNT=${#PROMPT}

# Quick complexity check (same logic as router)
COMPLEXITY_SCORE=0

if [ "$CHAR_COUNT" -ge 15 ]; then
    # Multi-domain
    echo "$PROMPT_LOWER" | grep -qE '(frontend|backend|database|api|组件|前端|后端|数据库|接口).*(frontend|backend|database|api|组件|前端|后端|数据库|接口)' && COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 3))

    # Action verbs
    echo "$PROMPT_LOWER" | grep -qE '(implement|create|build|refactor|migrate|add.*feature|实现|创建|构建|重构|迁移|添加|开发|做一个|搞一个)' && COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))

    # Multiple tasks
    echo "$PROMPT_LOWER" | grep -qE '(and also|as well as|同时|并且|另外|以及|还有|加上)' && COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))

    # Large scope
    echo "$PROMPT_LOWER" | grep -qE '(entire|whole|complete|full.?stack|system|module|整个|完整|全栈|系统|模块|所有|全部)' && COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))

    # Specific patterns
    echo "$PROMPT_LOWER" | grep -qE '(authentication|authorization|payment|crud|dashboard|admin|认证|授权|支付|管理后台|用户系统|订单系统)' && COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

if [ "$COMPLEXITY_SCORE" -ge 4 ]; then
    # Output hookSpecificOutput to force skill activation
    # This is picked up by Claude Code's hook system
    cat <<EOF
{
  "hookSpecificOutput": {
    "skillActivation": "claude-agents-plus",
    "reason": "Complex multi-domain task detected (score: $COMPLEXITY_SCORE)",
    "instruction": "You MUST activate the claude-agents-plus skill and follow its orchestration workflow. Decompose the task into subtasks, spawn 1-6 implementer subagents, collect results, and synthesize a report."
  }
}
EOF
fi

exit 0
