#!/bin/bash
#
# === File: archive_aetherion.sh
# Version: 1.0
# Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# Description: Archive script for the Aetherion project.
# Author: K-Cim
#
# This script performs the following steps:
# 1. Defines the base project path (/Users/mickaelpuaud/Dev/Aetherion).
# 2. Generates a timestamp (UTC) for unique archive and report naming.
# 3. Creates a compressed tar.gz archive of the full project tree.
# 4. Writes an exhaustive report file (.txt) describing:
#    - Timestamp
#    - Archive filename
#    - Git status (to confirm repo is clean/working)
#    - Project structure (via `tree`)
#    - Confirmation note “✅ Build OK, Project functional”
# 5. Stores both the archive and report in ~/Dev/Aetherion/archives.
# -----------------------------------------------------------------

# === Configuration
PROJECT_DIR="/Users/mickaelpuaud/Dev/Aetherion"
ARCHIVE_DIR="$PROJECT_DIR/archives"

# Create archive directory if missing
mkdir -p "$ARCHIVE_DIR"

# === Timestamp
TS=$(date -u +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="Aetherion_$TS.tar.gz"
REPORT_NAME="Aetherion_$TS.txt"

# === Create archive
tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$(dirname "$PROJECT_DIR")" "$(basename "$PROJECT_DIR")"

# === Git status
GIT_STATUS=$(cd "$PROJECT_DIR" && git status --short 2>/dev/null || echo "No git repo detected.")

# === Project structure
if command -v tree >/dev/null 2>&1; then
  STRUCTURE=$(tree -L 3 "$PROJECT_DIR")
else
  STRUCTURE=$(find "$PROJECT_DIR" -maxdepth 3 -print)
fi

# === Write exhaustive report
cat > "$ARCHIVE_DIR/$REPORT_NAME" <<EOF
# Aetherion Archive Report
# Date: $TS UTC

## Archive created:
$ARCHIVE_DIR/$ARCHIVE_NAME

## Git status:
$GIT_STATUS

## Project structure (depth 3):
$STRUCTURE

## Confirmation:
✅ Build OK, Project functional.
EOF

echo "📦 Archive created: $ARCHIVE_DIR/$ARCHIVE_NAME"
echo "📝 Report written:  $ARCHIVE_DIR/$REPORT_NAME"
