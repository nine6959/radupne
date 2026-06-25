#!/usr/bin/env bash
# Periodic skill drift review.
#
# Re-fetches each upstream source listed in .claude/skills/SKILLS-MANIFEST.json,
# diffs it against the vendored copy under .claude/skills/, and reports drift.
#
# Exit codes:
#   0  no drift  (vendored skills match upstream)
#   1  drift detected (a report is written to the path in $REPORT, default stdout)
#   2  error (network/tooling)
#
# It NEVER modifies the vendored skills. Updating is a human decision made after
# reviewing the reported diff.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"
MANIFEST="$SKILLS_DIR/SKILLS-MANIFEST.json"
REPORT="${REPORT:-/dev/stdout}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

CACERT_FLAG=""
[ -f /root/.ccr/ca-bundle.crt ] && CACERT_FLAG="--cacert /root/.ccr/ca-bundle.crt"

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required" >&2; exit 2; }

drift=0
{
  echo "# Skill drift review — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  count=$(jq '.sources | length' "$MANIFEST")
  for i in $(seq 0 $((count - 1))); do
    repo=$(jq -r ".sources[$i].repo" "$MANIFEST")
    branch=$(jq -r ".sources[$i].branch" "$MANIFEST")
    srcpath=$(jq -r ".sources[$i].sourcePath" "$MANIFEST")
    display=$(jq -r ".sources[$i].displayName" "$MANIFEST")
    vendoredAs=$(jq -r ".sources[$i].vendoredAs // empty" "$MANIFEST")

    tarball="$WORK/src-$i.tar.gz"
    if ! curl -fsSL $CACERT_FLAG -o "$tarball" \
        "https://codeload.github.com/$repo/tar.gz/refs/heads/$branch"; then
      echo "## ⚠️ $display ($repo) — FETCH FAILED"; echo
      drift=1; continue
    fi
    ex="$WORK/ex-$i"; mkdir -p "$ex"
    tar -xzf "$tarball" -C "$ex" --strip-components=1 2>/dev/null

    # Compare each vendored skill against its upstream counterpart.
    for skill in $(jq -r ".sources[$i].skills[]" "$MANIFEST"); do
      if [ -n "$vendoredAs" ]; then
        local_dir="$SKILLS_DIR/$vendoredAs"           # single-skill repo (e.g. watch)
        up_dir="$ex"                                   # compare repo root subset
      else
        local_dir="$SKILLS_DIR/$skill"
        up_dir="$ex/$srcpath/$skill"
      fi
      [ -d "$local_dir" ] || { echo "## ⚠️ $display / $skill — vendored copy missing"; echo; drift=1; continue; }
      [ -d "$up_dir" ]    || { echo "## ⚠️ $display / $skill — upstream path gone (renamed/removed)"; echo; drift=1; continue; }

      # Diff only files that exist in the vendored copy (the watch skill is assembled).
      changed=""
      while IFS= read -r f; do
        rel="${f#"$local_dir/"}"
        if [ ! -f "$up_dir/$rel" ]; then
          changed+=$'\n'"  - removed upstream: $rel"
        elif ! diff -q "$f" "$up_dir/$rel" >/dev/null 2>&1; then
          changed+=$'\n'"  - changed: $rel"
        fi
      done < <(find "$local_dir" -type f)

      if [ -n "$changed" ]; then
        echo "## 🔶 $display / \`$skill\` — DRIFT ($repo@$branch)"
        echo "$changed"
        echo
        drift=1
      fi
    done
  done

  if [ "$drift" -eq 0 ]; then
    echo "✅ No drift. All vendored skills match upstream."
  else
    echo "---"
    echo "Drift detected. Review the diffs above and update the vendored copies"
    echo "(re-run the install) only after confirming the changes are benign."
  fi
} > "$REPORT"

exit "$drift"
