<div align="center">

# Claude Code Custom Statusline

<strong>Upgrade your Claude Code status bar from plain text to a visual progress bar</strong>

<p>
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Claude_Code-Addon-orange?style=flat-square" alt="Claude Code">
  <img src="https://img.shields.io/github/license/bokiko/claude-statusline?style=flat-square" alt="License">
  <img src="https://img.shields.io/github/last-commit/bokiko/claude-statusline?style=flat-square" alt="Last Commit">
</p>

</div>

---

## What Is This?

Claude Code shows a plain text statusline at the bottom of your terminal:

```
83.9k 41%
```

This addon replaces it with a **visual progress bar** with model, git, and cost info:

```
[██████░░░░░░░░░] 41% | Sonnet | main | $0.03
```

No configuration files to edit. No dependencies to install. No `jq` required. Just one script.

---

## Before & After

```
BEFORE (default):
  83.9k 41%

AFTER (this addon):
  [██████░░░░░░░░░] 41% | Sonnet | main | $0.03
```

The bar changes color as your context fills up:

| Context Used | Color | What It Looks Like |
|--------------|-------|--------------------|
| **Under 60%** | Green | `[█████░░░░░░░░░] 34% \| Sonnet \| main \| $0.02` |
| **60% - 79%** | Yellow | `[█████████░░░░░░] 65% \| Opus \| main U:2 \| $0.15` |
| **80%+** | Red | `⚠ [████████████░░░] 85% \| Opus \| main \| $0.89` |

When running as a sub-agent, the agent name appears in parentheses:
```
[██████░░░░░░░░░] 72% | Opus (debug-agent) | feat/auth | $0.19
```

---

## Quick Start

### Step 1: Download the script

Open your terminal and paste this:

```bash
mkdir -p ~/.claude/scripts
curl -o ~/.claude/scripts/status.sh \
  "https://raw.githubusercontent.com/bokiko/claude-statusline/main/scripts/claude-statusline.sh"
chmod +x ~/.claude/scripts/status.sh
```

### Step 2: Tell Claude Code to use it

Open the file `~/.claude/settings.json` in any text editor.

If the file **already exists**, add the `statusLine` section inside the top-level `{ }`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "$HOME/.claude/scripts/status.sh"
  }
}
```

If the file **doesn't exist yet**, create it with exactly the content above.

### Step 3: Restart Claude Code

Close and reopen Claude Code. The new statusline appears immediately.

**That's it. You're done.**

---

## Alternative: Install from Source

```bash
git clone https://github.com/bokiko/claude-statusline.git
cd claude-statusline
bash install.sh
```

The installer copies the script and tells you what to add to settings.json.

---

## Features

<table>
<tr>
<td width="50%">

### Context Awareness
- Visual progress bar (15 characters wide)
- Color-coded: green → yellow → red
- Warning icon at 80%+ usage
- Uses Claude Code's built-in context percentage

</td>
<td width="50%">

### Model & Session Info
- Current model name (Sonnet / Opus / Haiku)
- Sub-agent name when running inside an agent
- Session cost in USD (`$0.042`)

</td>
</tr>
<tr>
<td width="50%">

### Git Status
- Current branch name
- Staged (S), unstaged (U), and added (A) file counts
- Truncates long branch names cleanly

</td>
<td width="50%">

### Zero Dependencies
- Pure bash — no `jq`, no `python`, no npm
- Works on any system with bash 4+ and git

</td>
</tr>
</table>

---

## Works Great With

### [BloxCue](https://github.com/bokiko/bloxcue)

Reduce Claude Code context usage by 90% with on-demand memory retrieval.

The statusline's context percentage becomes even more useful when paired with BloxCue — you'll see exactly how much context you're saving in real time. As BloxCue keeps your context lean, the progress bar stays green longer.

---

## Configuration

You can customize the script by editing `~/.claude/scripts/status.sh`:

| Variable | Default | What It Does |
|----------|---------|--------------|
| `bar_width` | `15` | How many characters wide the progress bar is |

---

## Project Structure

```
claude-statusline/
├── scripts/
│   └── claude-statusline.sh   # The statusline script
├── install.sh                  # One-command installer
├── LICENSE                     # MIT
└── README.md
```

---

## How It Works

Claude Code pipes JSON to the statusline command via stdin. The script reads:

| JSON field | What it shows |
|------------|---------------|
| `context_window.used_percentage` | Progress bar + percentage |
| `model.display_name` | Model name (Sonnet / Opus / Haiku) |
| `agent.name` | Sub-agent name (if running inside an agent) |
| `workspace.current_dir` | Used for git status |
| `cost.total_cost_usd` | Session cost in USD |

Parsed using pure bash (`grep`/`sed`) — no `jq` needed.

---

## Requirements

| Requirement | Why |
|-------------|-----|
| [Claude Code CLI](https://claude.ai/code) | This is an addon for Claude Code |
| Bash 4+ | Uses bash-specific features for the progress bar |
| `git` | Shows branch and file status (optional — works without it) |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Statusline doesn't appear | Make sure `~/.claude/settings.json` has the `statusLine` section and restart Claude Code |
| Shows `0%` always | Make sure the script is executable: `chmod +x ~/.claude/scripts/status.sh` |
| No git info showing | Make sure you're in a git repository |
| No model name showing | Requires Claude Code v1.x+ (the `model.display_name` field) |
| Permission denied | Run `chmod +x ~/.claude/scripts/status.sh` |

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made by <a href="https://github.com/bokiko">@bokiko</a>
</p>
