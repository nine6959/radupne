# Vendored Claude Code Skills

This directory contains Claude Code skills vendored (copied) from six third-party
sources featured in [this YouTube video](https://youtu.be/UClLUoGaCxU). They were
installed here as **project skills** so they are active when working in this repo.

## Why vendored (copied) instead of `/plugin install`?

- **Versions are pinned.** A copied snapshot never auto-updates, so a future
  upstream change (including a malicious one) cannot silently land on your machine.
- **Changes are reviewed before adoption.** The periodic review automation
  (`.github/workflows/skill-review.yml`) diffs upstream against these copies and
  opens an issue when they drift. Updates happen only after a human approves.

The trade-off: any auto-running hooks/scripts in a skill still execute (frozen at
the snapshot), and the *initial* snapshot is trusted as-is. See per-source risk
notes in [`SKILLS-MANIFEST.json`](./SKILLS-MANIFEST.json).

## Installed skills

| Source | Repo | Risk | Notes |
|---|---|---|---|
| Karpathy Guidelines | `multica-ai/andrej-karpathy-skills` | 🟢 low | Docs only, no code |
| claude-video (`watch`) | `bradautomates/claude-video` | 🟡 medium | Needs yt-dlp/ffmpeg; SessionStart hook + Python |
| Superpowers (14) | `obra/superpowers` | 🟢 low | Well-known maintainer; upstream hook NOT vendored |
| Understand-Anything (8) | `Lum1104/Understand-Anything` | 🟡 medium | Needs npm CLI backend (not vendored) |
| agentmemory (16) | `rohitg00/agentmemory` | 🟡 medium | Needs MCP server + npm tool (not vendored) |
| Skill Creator | covered by Superpowers `writing-skills` | 🟢 low | Bonus from the video |

## Extra setup required for full functionality

These vendored skills include the SKILL.md instructions, but some rely on backends
that are **not** in this repo:

- **claude-video**: install `yt-dlp` and `ffmpeg` (and optionally Whisper).
- **understand-anything**: build the upstream plugin (npm/pnpm) so the `understand` CLI exists.
- **agentmemory**: install the agentmemory tool and configure its MCP server.

## Periodic security review

`.github/workflows/skill-review.yml` re-fetches each upstream repo on a schedule
and diffs it against the vendored copy here. If anything changed, it opens a
GitHub issue listing the drift so you can review the diff **before** deciding to
update. It never auto-applies changes.

To review manually at any time:

```bash
scripts/review-skills.sh
```
