#!/usr/bin/env bash
# tools/ingest.sh — wrap repomix for the orchestrator's "ingest target repo" step
#
# Usage:
#   ./tools/ingest.sh <target-repo-path-or-url> <project-slug> [extra-repomix-args...]
#
# Examples:
#   ./tools/ingest.sh /Users/aman/code/omnilink-backend link-shortener-mvp
#   ./tools/ingest.sh https://github.com/yamadashy/repomix repomix-review --include "src/**/*.ts"
#
# Output:
#   workspace/<slug>/ingested/repomix-output.xml   (compressed, AI-friendly)
#   workspace/<slug>/ingested/manifest.txt         (file list with token counts)

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <target-repo-path-or-url> <project-slug> [extra-repomix-args...]" >&2
  exit 1
fi

TARGET=$1
SLUG=$2
shift 2

THEAITEAM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$THEAITEAM_ROOT/workspace/$SLUG/ingested"
mkdir -p "$OUTPUT_DIR"

# Detect remote vs local
REPOMIX_TARGET_FLAG=""
if [[ "$TARGET" =~ ^https?:// ]] || [[ "$TARGET" =~ ^git@ ]]; then
  REPOMIX_TARGET_FLAG="--remote $TARGET"
  CWD_FOR_REPOMIX="$THEAITEAM_ROOT"
else
  if [ ! -d "$TARGET" ]; then
    echo "Error: local target '$TARGET' is not a directory" >&2
    exit 2
  fi
  CWD_FOR_REPOMIX="$TARGET"
fi

echo "→ Ingesting: $TARGET"
echo "→ Slug:      $SLUG"
echo "→ Output:    $OUTPUT_DIR/"

cd "$CWD_FOR_REPOMIX"

# shellcheck disable=SC2086
npx --yes repomix@latest \
  $REPOMIX_TARGET_FLAG \
  --style xml \
  --compress \
  --token-count-tree \
  --output "$OUTPUT_DIR/repomix-output.xml" \
  "$@"

# Generate a manifest summary
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$OUTPUT_DIR/manifest.txt"
echo "Target:    $TARGET" >> "$OUTPUT_DIR/manifest.txt"
echo "Output:    $(du -h "$OUTPUT_DIR/repomix-output.xml" | cut -f1)" >> "$OUTPUT_DIR/manifest.txt"
echo "Lines:     $(wc -l < "$OUTPUT_DIR/repomix-output.xml")" >> "$OUTPUT_DIR/manifest.txt"

echo
echo "✅ Ingest complete."
echo "   $OUTPUT_DIR/repomix-output.xml"
echo "   $OUTPUT_DIR/manifest.txt"
echo
echo "Next: a role will read this with 'Read $OUTPUT_DIR/repomix-output.xml' or grep into specific sections."
