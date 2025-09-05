#!/usr/bin/env bash
set -euo pipefail

# === File: git_save.sh
# Description: Sauvegarde Git + archive + rapport pour le projet Aetherion
# Author: K-Cim
# Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# ----------------------------
# CONFIG
# ----------------------------
PROJECT_DIR="/Users/mickaelpuaud/Dev/Aetherion"   # chemin de ton projet
ARCHIVE_DIR="$PROJECT_DIR/archives"
BRANCH="main"                                     # branche par défaut
TAG_PREFIX="snapshot"

# ----------------------------
# Fonctions utilitaires
# ----------------------------
bold() { printf "\033[1m%s\033[0m\n" "$*"; }
info() { printf "• %s\n" "$*"; }
ok()   { printf "✅ %s\n" "$*"; }
warn() { printf "⚠️  %s\n" "$*"; }
err()  { printf "❌ %s\n" "$*" >&2; }

# ----------------------------
# Préparation
# ----------------------------
cd "$PROJECT_DIR"
mkdir -p "$ARCHIVE_DIR"

TS="$(date -u +"%Y-%m-%d_%H-%M-%S")"
TAG="$TAG_PREFIX-$TS"
ARCHIVE_NAME="Aetherion_${TS}.tar.gz"
REPORT_NAME="Aetherion_${TS}.txt"

bold "=== Sauvegarde Git Aetherion ($TS UTC) ==="

# ----------------------------
# Init repo si besoin
# ----------------------------
if [ ! -d ".git" ]; then
  info "Initialisation du dépôt Git…"
  git init
  git checkout -b "$BRANCH"
  ok "Repo initialisé."
fi

# ----------------------------
# Git add + commit
# ----------------------------
info "Ajout des fichiers (git add -A)…"
git add -A

if git diff --cached --quiet; then
  warn "Aucune modification à committer."
else
  git commit -m "chore(snapshot): sauvegarde $TS"
  ok "Commit créé."
fi

# ----------------------------
# Création du tag
# ----------------------------
if git rev-parse "$TAG" >/dev/null 2>&1; then
  warn "Tag $TAG existe déjà, on le recrée."
  git tag -d "$TAG"
fi
git tag -a "$TAG" -m "Aetherion snapshot $TS"
ok "Tag $TAG créé."

# ----------------------------
# Archive + rapport
# ----------------------------
info "Création de l’archive…"
git archive --format=tar.gz -o "$ARCHIVE_DIR/$ARCHIVE_NAME" "$TAG"
ok "Archive : $ARCHIVE_DIR/$ARCHIVE_NAME"

info "Rédaction du rapport…"
LAST_COMMIT="$(git log -1 --pretty=format:'%h %ad %an — %s' --date=iso)"
STRUCTURE="$(find "$PROJECT_DIR/Aetherion" -maxdepth 3 -print)"

cat > "$ARCHIVE_DIR/$REPORT_NAME" <<EOF
# Aetherion — Git Snapshot Report
Date (UTC): $TS
Tag: $TAG
Branch: $BRANCH

Dernier commit:
$LAST_COMMIT

Archive:
$ARCHIVE_DIR/$ARCHIVE_NAME

Structure (profondeur 3):
$STRUCTURE
EOF

ok "Rapport : $ARCHIVE_DIR/$REPORT_NAME"

# ----------------------------
# Push optionnel
# ----------------------------
if git remote get-url origin >/dev/null 2>&1; then
  info "Push vers origin…"
  git push -u origin "$BRANCH"
  git push origin "$TAG"
  ok "Push terminé."
else
  warn "Pas de remote configuré (origin)."
fi

bold "=== Sauvegarde terminée ==="
