#!/usr/bin/env bash
# install-skills.sh — install the same 6 skill sets on any computer.
#
# Self-contained: copy ONLY this one file to a new machine and run it.
# It downloads each skill from its original GitHub repo and installs them.
#
# Usage:
#   ./install-skills.sh                 # install to ~/.claude/skills (personal: works in ALL projects on this machine)
#   ./install-skills.sh --project       # install to ./.claude/skills (current project only)
#   ./install-skills.sh --target DIR    # install to a custom directory
#
# Requirements: bash, curl, tar  (macOS/Linux. On Windows use Git Bash or WSL.)

set -uo pipefail

# ---- pick install target ---------------------------------------------------
TARGET="$HOME/.claude/skills"
while [ $# -gt 0 ]; do
  case "$1" in
    --project) TARGET="$(pwd)/.claude/skills"; shift ;;
    --target)  TARGET="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

command -v curl >/dev/null || { echo "ERROR: curl is required"; exit 1; }
command -v tar  >/dev/null || { echo "ERROR: tar is required";  exit 1; }

echo "Installing skills into: $TARGET"
mkdir -p "$TARGET"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

# Fetch a repo tarball (tries main then master) and extract to $WORK/<key>.
fetch() {
  local key="$1" repo="$2"
  for br in main master; do
    if curl -fsSL -o "$WORK/$key.tgz" "https://codeload.github.com/$repo/tar.gz/refs/heads/$br" 2>/dev/null; then
      mkdir -p "$WORK/$key"
      tar -xzf "$WORK/$key.tgz" -C "$WORK/$key" --strip-components=1 2>/dev/null && return 0
    fi
  done
  echo "  ! FAILED to fetch $repo"; return 1
}

copy_dir() { # src dest  -> copy src into dest/<basename src>
  local src="$1" dest="$2"
  [ -d "$src" ] || return 0
  rm -rf "$dest/$(basename "$src")"
  cp -r "$src" "$dest/$(basename "$src")"
}

n=0
echo "==> Karpathy Guidelines (multica-ai/andrej-karpathy-skills)"
fetch karpathy multica-ai/andrej-karpathy-skills && {
  copy_dir "$WORK/karpathy/skills/karpathy-guidelines" "$TARGET"; n=$((n+1)); }

echo "==> claude-video / watch (bradautomates/claude-video)"
fetch claudevideo bradautomates/claude-video && {
  d="$TARGET/watch"; mkdir -p "$d"
  cp "$WORK/claudevideo/SKILL.md" "$d/" 2>/dev/null
  cp "$WORK/claudevideo/README.md" "$d/" 2>/dev/null
  cp "$WORK/claudevideo/LICENSE" "$d/" 2>/dev/null
  for sub in commands scripts hooks; do cp -r "$WORK/claudevideo/$sub" "$d/" 2>/dev/null; done
  n=$((n+1)); }

echo "==> Superpowers, 14 skills (obra/superpowers)"
fetch superpowers obra/superpowers && {
  for s in "$WORK"/superpowers/skills/*/; do copy_dir "$s" "$TARGET"; n=$((n+1)); done; }

echo "==> Understand-Anything, 8 skills (Lum1104/Understand-Anything)"
fetch understand Lum1104/Understand-Anything && {
  for s in "$WORK"/understand/understand-anything-plugin/skills/*/; do copy_dir "$s" "$TARGET"; n=$((n+1)); done; }

echo "==> agentmemory skills (rohitg00/agentmemory)"
fetch agentmemory rohitg00/agentmemory && {
  for s in "$WORK"/agentmemory/plugin/skills/*/; do copy_dir "$s" "$TARGET"; n=$((n+1)); done; }

echo
echo "Done. Installed/updated $n skill folders in: $TARGET"
echo "Open Claude Code and they will be auto-discovered."
echo
echo "Note: 'watch' also needs yt-dlp + ffmpeg; 'understand-*' needs its npm CLI;"
echo "'agentmemory' needs its MCP server. See each skill's README for backend setup."
