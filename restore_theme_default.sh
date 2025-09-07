#!/usr/bin/env bash
set -euo pipefail

PROJECT="/Users/mickaelpuaud/Dev/Aetherion-2"
REL_PATH="Aetherion/Features/Settings/ThemeDefautlView.swift"
TARGET="$PROJECT/$REL_PATH"
TS="$(date -u +%Y-%m-%d_%H-%M-%S)"

echo "📦 Projet : $PROJECT"
echo "🎯 Fichier : $REL_PATH"
cd "$PROJECT"

# 0) Sauvegarde de la version actuelle si elle existe
if [[ -f "$TARGET" ]]; then
  cp -v "$TARGET" "${TARGET}.broken-${TS}"
  echo "🔒 Copie de sécurité : ${TARGET}.broken-${TS}"
fi

restore_from_git_rev () {
  local rev="$1"
  if git cat-file -e "${rev}:${REL_PATH}" 2>/dev/null; then
    echo "↩️  Restauration depuis ${rev}:${REL_PATH}"
    git show "${rev}:${REL_PATH}" > "$TARGET"
    return 0
  fi
  return 1
}

# 1) Si dépôt Git : essayer HEAD
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if restore_from_git_rev HEAD; then
    echo "✅ Restauré depuis HEAD."
    exit 0
  fi
  # 2) Essayer le dernier tag (snapshot le plus récent)
  LAST_TAG="$(git for-each-ref --sort=-taggerdate --format='%(refname:short)' refs/tags | head -1 || true)"
  if [[ -n "${LAST_TAG:-}" ]]; then
    if restore_from_git_rev "$LAST_TAG"; then
      echo "✅ Restauré depuis le tag : $LAST_TAG"
      exit 0
    fi
  fi
else
  echo "⚠️  Pas de dépôt Git dans $PROJECT"
fi

# 3) Chercher une copie locale de secours
echo "🔎 Recherche de copies locales (_backup*, *.bak*)…"
CANDIDATE="$(find "$PROJECT" -type f \( -name "ThemeDefautlView.swift" -o -name "ThemeDefautlView.swift.bak*" \) \
  | grep -E "_backup|\.bak" | xargs -I{} stat -f "%m\t%N" {} 2>/dev/null | sort -nr | head -1 | cut -f2-)"
if [[ -n "${CANDIDATE:-}" && -f "$CANDIDATE" ]]; then
  echo "↩️  Copie depuis : $CANDIDATE"
  cp -v "$CANDIDATE" "$TARGET"
  echo "✅ Restauré depuis une sauvegarde locale."
  exit 0
fi

# 4) Chercher dans des archives .tar.gz
echo "🔎 Recherche dans archives .tar.gz…"
ARCH_ROOTS=(
  "/Users/mickaelpuaud/Dev/Aetherion-2/archives"
  "/Users/mickaelpuaud/Dev/Aetherion/archives"
)
for ROOT in "${ARCH_ROOTS[@]}"; do
  [[ -d "$ROOT" ]] || continue
  # archives triées par date (les plus récentes d'abord)
  while IFS= read -r TARGZ; do
    if tar -tzf "$TARGZ" "$REL_PATH" >/dev/null 2>&1; then
      echo "↩️  Extraction depuis archive : $TARGZ"
      tar -xzf "$TARGZ" "$REL_PATH" -C "$PROJECT"
      echo "✅ Restauré depuis archive."
      exit 0
    fi
  done < <(ls -1t "$ROOT"/*.tar.gz 2>/dev/null || true)
done

echo "❌ Échec : impossible de retrouver une version antérieure."
echo "   – Vérifie Time Machine si activé."
exit 1
