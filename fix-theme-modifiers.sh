#!/usr/bin/env bash
set -euo pipefail

# Dossiers à traiter
PATHS=("Aetherion/UI" "Aetherion/Features")

# 1) Dry-run : lister les occurrences suspectes
echo "=== Dry-run: occurrences actuelles ==="
grep -RIn --color=always \
  -e '\.themedScreenBackground\(\s*\$*themeManager' \
  -e '\.themedForeground\(\s*\$*themeManager' \
  -e '\.themedSecondary\(\s*\$*themeManager' \
  -e '\.tint\(\s*\$*themeManager' \
  "${PATHS[@]}" || true

echo
read -p "Continuer avec les remplacements ? (y/N) " yn
[[ "${yn:-N}" == "y" || "${yn:-N}" == "Y" ]] || { echo "Abort."; exit 1; }

# 2) Remplacements (in-place) + sauvegardes .bak
# Remplace tout argument basé sur themeManager / $themeManager par la valeur correcte.

# a) themedScreenBackground(...) -> themedScreenBackground(themeManager.theme)
perl -0777 -pi.bak -e '
  s/\.themedScreenBackground\(\s*\$?themeManager[^\)]*\)/.themedScreenBackground(themeManager.theme)/g
' "${PATHS[@]}"/*/*.swift "${PATHS[@]}"/*/*/*.swift 2>/dev/null || true

# b) themedForeground(...) -> themedForeground(themeManager.theme)
perl -0777 -pi.bak -e '
  s/\.themedForeground\(\s*\$?themeManager[^\)]*\)/.themedForeground(themeManager.theme)/g
' "${PATHS[@]}"/*/*.swift "${PATHS[@]}"/*/*/*.swift 2>/dev/null || true

# c) themedSecondary(...) -> themedSecondary(themeManager.theme)
perl -0777 -pi.bak -e '
  s/\.themedSecondary\(\s*\$?themeManager[^\)]*\)/.themedSecondary(themeManager.theme)/g
' "${PATHS[@]}"/*/*.swift "${PATHS[@]}"/*/*/*.swift 2>/dev/null || true

# d) tint(...) basé sur themeManager -> themedTint(themeManager.accentColor)
perl -0777 -pi.bak -e '
  s/\.tint\(\s*\$?themeManager[^\)]*\)/.themedTint(themeManager.accentColor)/g
' "${PATHS[@]}"/*/*.swift "${PATHS[@]}"/*/*/*.swift 2>/dev/null || true

echo "=== Terminé. Montre les diffs ci-dessous ==="
git -c color.ui=always diff -- "${PATHS[@]}" | cat

echo
echo "Si tout est OK :"
echo "  git add -A && git commit -m \"chore: fix(theme): pass Theme values to modifiers (no EnvironmentObject in extensions)\""
echo
echo "Pour RESTAURER un fichier: récupère *.bak (ex: mv F.swift.bak F.swift) ou fais git checkout -- <file>."
