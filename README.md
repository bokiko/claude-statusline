# Claude Code Custom Statusline

Upgrade from plain text to a visual progress bar.

```
Default                Custom
83.9k 41%              [██████░░░░░░░░░] 41% | main | current task
```

## Features

- **Visual progress bar** instead of plain numbers
- **Color-coded warnings** — green (<60%), yellow (60-79%), red (80%+)
- **Git status** — branch + staged/unstaged/added counts
- **Continuity ledger** — last completed task → current focus

## Display Examples

```
< 60%:   [█████░░░░░░░░░░] 34% | main | ✓ fixed auth → add tests
60-79%:  [█████████░░░░░░] 65% | main U:2 | refactoring api
>= 80%:  ⚠ [████████████░░░] 85% | main | compress context now
```

## Install

### Quick Install

```bash
mkdir -p ~/.claude/scripts
curl -o ~/.claude/scripts/status.sh \
  "https://raw.githubusercontent.com/bokiko/claude-statusline/main/scripts/claude-statusline.sh"
chmod +x ~/.claude/scripts/status.sh
```

### Manual Install

```bash
git clone https://github.com/bokiko/claude-statusline.git
mkdir -p ~/.claude/scripts
cp claude-statusline/scripts/claude-statusline.sh ~/.claude/scripts/status.sh
chmod +x ~/.claude/scripts/status.sh
```

### Enable

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "$HOME/.claude/scripts/status.sh"
  }
}
```

Restart Claude Code and the statusline appears immediately.

## How It Works

The script reads Claude Code's JSON status input via stdin, which includes:

- `context_window.current_usage` — token counts (input, cache read, cache creation)
- `context_window.context_window_size` — max context size
- `workspace.current_dir` — current working directory

It then renders a 15-character progress bar with ANSI color codes, appends git branch info, and shows continuity ledger status if available.

## Configuration

Edit the script to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `bar_width` | `15` | Width of the progress bar in characters |
| `system_overhead` | `45000` | Estimated system prompt token overhead |

## Requirements

- Claude Code CLI
- `jq` (for JSON parsing)
- `git` (for branch/status display)
- Bash 4+

## License

MIT
