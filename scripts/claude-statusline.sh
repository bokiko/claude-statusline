#!/bin/bash
# ============================================================================
# Claude Code Custom Statusline with Progress Bar
# ============================================================================
# Author: bokiko
# Description: Custom statusline for Claude Code CLI showing context usage
#              as a visual progress bar with color-coded warnings.
#
# Requirements: bash, grep, sed, git (no jq needed)
#
# Features:
#   - Visual progress bar [████████░░░░░░░] instead of plain text
#   - Color-coded: green (<60%), yellow (60-79%), red (>=80%)
#   - Model name (Sonnet / Opus / Haiku)
#   - Agent name when running as a sub-agent
#   - Git branch + staged/unstaged/added file counts
#   - Session cost in USD
#
# Installation:
#   1. Copy to ~/.claude/scripts/status.sh
#   2. Make executable: chmod +x ~/.claude/scripts/status.sh
#   3. Add to ~/.claude/settings.json:
#      {
#        "statusLine": {
#          "type": "command",
#          "command": "$HOME/.claude/scripts/status.sh"
#        }
#      }
#
# Display Examples:
#   < 60%:  [█████░░░░░░░░░░] 34% | Sonnet | main | $0.02
#   60-79%: [█████████░░░░░░] 65% | Opus | main U:2 | $0.15        (yellow)
#   >= 80%: ⚠ [████████████░░░] 85% | Opus (debug-agent) | main | $0.89  (red)
# ============================================================================

input=$(cat)

project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# ─────────────────────────────────────────────────────────────────
# JSON helpers (pure bash — no jq required)
# ─────────────────────────────────────────────────────────────────
# Extract integer value: "key":123 → 123
get_num() {
    echo "$input" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*[0-9]+" | grep -oE '[0-9]+$' | head -1
}
# Extract float value: "key":0.0123 → 0.0123
get_float() {
    echo "$input" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*[0-9]+\.?[0-9]*" | grep -oE '[0-9]+\.?[0-9]*$' | head -1
}
# Extract string value: "key":"value" → value
get_str() {
    local match
    match=$(echo "$input" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1)
    echo "$match" | sed 's/^[^:]*:[[:space:]]*"//;s/"$//'
}

cwd=$(get_str "current_dir")
[[ -z "$cwd" ]] && cwd=$(get_str "cwd")
[[ -z "$cwd" ]] && cwd="$project_dir"

# ─────────────────────────────────────────────────────────────────
# CONTEXT - Usage percentage + progress bar
# ─────────────────────────────────────────────────────────────────
context_pct=$(get_num "used_percentage")
context_pct=${context_pct:-0}
context_pct=$((context_pct + 0))
[[ "$context_pct" -gt 100 ]] && context_pct=100

# Write for hooks (per-session to avoid multi-instance conflicts)
session_id="${CLAUDE_SESSION_ID:-$PPID}"
echo "$context_pct" > "/tmp/claude-context-pct-${session_id}.txt"

bar_width=15
filled=$((context_pct * bar_width / 100))
empty=$((bar_width - filled))

bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# ─────────────────────────────────────────────────────────────────
# MODEL - Display name + optional agent name
# ─────────────────────────────────────────────────────────────────
model=$(get_str "display_name")
agent=$(get_str "name")  # present only when running as a sub-agent

model_info=""
if [[ -n "$model" ]]; then
    if [[ -n "$agent" ]]; then
        model_info="$model \033[35m($agent)\033[0m"
    else
        model_info="$model"
    fi
fi

# ─────────────────────────────────────────────────────────────────
# GIT - Branch + S/U/A counts
# ─────────────────────────────────────────────────────────────────
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ ${#branch} -gt 12 ]] && branch="${branch:0:10}.."

    staged=$(git -C "$cwd" --no-optional-locks diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    unstaged=$(git -C "$cwd" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    added=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    counts=""
    [[ "$staged" -gt 0 ]] && counts="S:$staged"
    [[ "$unstaged" -gt 0 ]] && counts="${counts:+$counts }U:$unstaged"
    [[ "$added" -gt 0 ]] && counts="${counts:+$counts }A:$added"

    if [[ -n "$counts" ]]; then
        git_info="$branch \033[33m$counts\033[0m"
    else
        git_info="\033[32m$branch\033[0m"
    fi
fi

# ─────────────────────────────────────────────────────────────────
# COST - Session USD spend
# ─────────────────────────────────────────────────────────────────
cost_raw=$(get_float "total_cost_usd")
cost_info=""
if [[ -n "$cost_raw" && "$cost_raw" != "0" ]]; then
    # Format: $0.042 (3 decimal places via awk)
    cost_info=$(awk -v c="$cost_raw" 'BEGIN { printf "$%.3f", c }')
fi

# ─────────────────────────────────────────────────────────────────
# OUTPUT - Assemble color-coded statusline
# ─────────────────────────────────────────────────────────────────
build_output() {
    local ctx_display="$1"
    local out="$ctx_display"
    [[ -n "$model_info" ]] && out="$out | $model_info"
    [[ -n "$git_info" ]]   && out="$out | $git_info"
    [[ -n "$cost_info" ]]  && out="$out | \033[36m$cost_info\033[0m"
    echo "$out"
}

if [[ "$context_pct" -ge 80 ]]; then
    ctx_display="\033[31m⚠ [${bar}] ${context_pct}%\033[0m"
elif [[ "$context_pct" -ge 60 ]]; then
    ctx_display="\033[33m[${bar}] ${context_pct}%\033[0m"
else
    ctx_display="\033[32m[${bar}] ${context_pct}%\033[0m"
fi

echo -e "$(build_output "$ctx_display")"
