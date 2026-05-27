#!/bin/bash
# Claude Agents Plus - Auto-routing hook
# Reads user input from stdin, assesses complexity, outputs routing signal

# Read the JSON input from stdin
INPUT=$(cat)

# Extract the prompt from the JSON
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Convert to lowercase for analysis
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Calculate length (works better for Chinese)
CHAR_COUNT=${#PROMPT}

# Skip very short messages (greetings, simple questions)
if [ "$CHAR_COUNT" -lt 15 ]; then
    exit 0
fi

# Skip if it's clearly a simple question or greeting
if echo "$PROMPT_LOWER" | grep -qiE '^(hi|hello|hey|what is|who is|when was|where is|how to|explain|你好|谢谢|什么是|定义)'; then
    exit 0
fi

# Complexity indicators - multi-domain signals
COMPLEXITY_SCORE=0

# Multi-file / multi-component indicators (English + Chinese)
if echo "$PROMPT_LOWER" | grep -qE '(frontend|backend|database|api|组件|前端|后端|数据库|接口).*(frontend|backend|database|api|组件|前端|后端|数据库|接口)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 3))
fi

# Action verbs indicating implementation work
if echo "$PROMPT_LOWER" | grep -qE '(implement|create|build|refactor|migrate|add.*feature|实现|创建|构建|重构|迁移|添加|开发|做一个|搞一个)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# Multiple tasks indicated
if echo "$PROMPT_LOWER" | grep -qE '(and also|as well as|同时|并且|另外|以及|还有|加上)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# Large scope indicators
if echo "$PROMPT_LOWER" | grep -qE '(entire|whole|complete|full.?stack|system|module|整个|完整|全栈|系统|模块|所有|全部)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# Multi-step indicators
if echo "$PROMPT_LOWER" | grep -qE '(first.*then|step \d|phase \d|首先.*然后|第.*步|阶段|先.*再|先.*后)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# Specific complex task patterns
if echo "$PROMPT_LOWER" | grep -qE '(authentication|authorization|payment|crud|dashboard|admin|认证|授权|支付|管理后台|用户系统|订单系统)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# Testing + implementation
if echo "$PROMPT_LOWER" | grep -qE '(test|测试).*(implement|build|create|实现|构建|开发)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# DevOps / deployment
if echo "$PROMPT_LOWER" | grep -qE '(docker|kubernetes|deploy|ci.?cd|pipeline|容器|部署|流水线)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 1))
fi

# Architecture / design patterns
if echo "$PROMPT_LOWER" | grep -qE '(architecture|design pattern|microservice|monolith|架构|设计模式|微服务)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# Multiple files mentioned
if echo "$PROMPT_LOWER" | grep -qE '(\d+\s*(files?|个文件|个组件)|multiple|多个|很多)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 2))
fi

# If complexity score >= 4, trigger multi-agent orchestration
if [ "$COMPLEXITY_SCORE" -ge 4 ]; then
    echo "[SKILL_ROUTE] claude-agents-plus [/SKILL_ROUTE]"
    echo "[COMPLEXITY] high [/COMPLEXITY]"
fi

exit 0
