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

This addon replaces it with a **visual progress bar** that shows more at a glance:

```
[██████░░░░░░░░░] 41% | main | ✓ fixed auth → add tests
```

No configuration files to edit. No dependencies to install. Just one script.

---

## Before & After

```
BEFORE (default):
  83.9k 41%

AFTER (this addon):
  [██████░░░░░░░░░] 41% | main | ✓ fixed auth → add tests
```

The bar changes color as your context fills up:

| Context Used | Color | What It Looks Like |
|--------------|-------|--------------------|
| **Under 60%** | Green | `[█████░░░░░░░░░] 34% \| main` |
| **60% - 79%** | Yellow | `[█████████░░░░░░] 65% \| main U:2` |
| **80%+** | Red | `⚠ [████████████░░░] 85% \| main` |

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
- Tracks input, cache, and system tokens

</td>
<td width="50%">

### Git & Task Status
- Current branch name
- Staged (S), unstaged (U), and added (A) file counts
- Continuity ledger: last task done → current focus
- Truncates long names cleanly

</td>
</tr>
</table>

---

## Works With Continuous Claude

This statusline is designed to work perfectly with [**Continuous Claude v3**](https://github.com/parcadei/Continuous-Claude-v3) — a persistent, learning, multi-agent development environment built on Claude Code.

When you use Continuous Claude, the statusline automatically picks up:

| Feature | What It Shows |
|---------|---------------|
| **Continuity ledger** | Last completed task → current focus from your `CONTINUITY_CLAUDE-*.md` files |
| **Handoff awareness** | See what was done and what's next at a glance after resuming a session |
| **Context warnings** | Know when to create a handoff before context fills up |

If you're using Continuous Claude's handoff system, the statusline keeps you informed without breaking your flow. If you're not using Continuous Claude, the statusline works standalone — it simply skips the ledger section.

---

## Configuration

You can customize the script by editing `~/.claude/scripts/status.sh`:

| Variable | Default | What It Does |
|----------|---------|--------------|
| `bar_width` | `15` | How many characters wide the progress bar is |
| `system_overhead` | `45000` | Estimated system prompt size (affects % calculation) |

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

Claude Code pipes JSON to the statusline command via stdin. The JSON includes:

- **Token usage** — input tokens, cache read, cache creation
- **Context window size** — maximum allowed tokens
- **Workspace** — current working directory

The script uses `jq` to parse the JSON, calculates usage percentage, and renders a color-coded progress bar using ANSI escape codes. It then checks for git status and continuity ledger files in the project directory.

---

## Requirements

| Requirement | Why |
|-------------|-----|
| [Claude Code CLI](https://claude.ai/code) | This is an addon for Claude Code |
| `jq` | Parses the JSON input from Claude Code |
| `git` | Shows branch and file status (optional — works without it) |
| Bash 4+ | Uses bash-specific features for the progress bar |

Most systems already have these. To check:

```bash
jq --version && git --version && bash --version | head -1
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Statusline doesn't appear | Make sure `~/.claude/settings.json` has the `statusLine` section and restart Claude Code |
| Shows `0%` always | Check that `jq` is installed: `jq --version` |
| No git info showing | Make sure you're in a git repository |
| No task/ledger info | This requires [Continuous Claude](https://github.com/parcadei/Continuous-Claude-v3) continuity ledger files |
| Permission denied | Run `chmod +x ~/.claude/scripts/status.sh` |

---

## Roadmap

- [x] Visual progress bar with color coding
- [x] Git branch and file status
- [x] Continuity ledger integration
- [x] One-command installer
- [ ] Customizable themes
- [ ] Token cost estimation display

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made by <a href="https://github.com/bokiko">@bokiko</a>
</p>
