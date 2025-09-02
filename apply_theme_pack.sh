#!/usr/bin/env bash
set -euo pipefail

# === File: apply_theme_pack.sh
# Version: 1.0
# Description: Remplace/installe en une fois tous les fichiers Theme.* + vues associées.
# Author: K-Cim

# === CONFIG
BASE_DEFAULT="/Users/mickaelpuaud/Dev/Aetherion/Aetherion"
BASE="${BASE:-$BASE_DEFAULT}"               # dossier racine du code (celui qui contient App/, Core/, UI/, Features/)
AUTO_COMMIT="${AUTO_COMMIT:-no}"            # yes|no — fait un commit git si 'yes'
TS="$(date -u +"%Y-%m-%d_%H-%M-%S")"

say() { printf "• %s\n" "$*"; }
ok()  { printf "✅ %s\n" "$*"; }
warn(){ printf "⚠️  %s\n" "$*"; }
err() { printf "❌ %s\n" "$*\n" >&2; exit 1; }

[ -d "$BASE" ] || err "Le dossier BASE n'existe pas: $BASE (exporte BASE=/chemin/vers/Aetherion si besoin)."

say "Base: $BASE"
say "Horodatage: $TS UTC"

# === Dossiers à créer
mkdir -p "$BASE/UI/Theme" \
         "$BASE/UI/Components" \
         "$BASE/Core/Services" \
         "$BASE/Features/Settings"

backup_if_exists () {
  local path="$1"
  if [ -f "$path" ]; then
    mv "$path" "$path.bak-$TS"
    say "Backup: $(basename "$path").bak-$TS"
  fi
}

write_file () {
  local path="$1"
  local dir; dir="$(dirname "$path")"
  mkdir -p "$dir"
  backup_if_exists "$path"
  cat > "$path"
  say "Ecrit: $path"
}

# =========================================================
# 1) UI/Theme/Theme.swift
# =========================================================
write_file "$BASE/UI/Theme/Theme.swift" <<'EOF'
// === File: Theme.swift
// Version: 1.0
// Date: 2025-08-30
// Description: ThemeID and Theme model with presets.
// Author: K-Cim

import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable {
    case aetherionDark
    case aetherionLight

    var id: String { rawValue }
}

struct Theme {
    var id: ThemeID
    var background: Color
    var foreground: Color
    var secondary: Color
    var cardStartOpacity: Double
    var cardEndOpacity: Double
    var cornerRadius: CGFloat

    static func preset(_ id: ThemeID) -> Theme {
        switch id {
        case .aetherionDark:
            return Theme(
                id: id,
                background: .black,
                foreground: .white,
                secondary: .white.opacity(0.7),
                cardStartOpacity: 0.30,
                cardEndOpacity: 0.10,
                cornerRadius: 16
            )
        case .aetherionLight:
            return Theme(
                id: id,
                background: .white,
                foreground: .black,
                secondary: .black.opacity(0.7),
                cardStartOpacity: 0.08,
                cardEndOpacity: 0.02,
                cornerRadius: 16
            )
        }
    }
}
EOF

# =========================================================
# 2) UI/Theme/ThemeManager.swift
# =========================================================
write_file "$BASE/UI/Theme/ThemeManager.swift" <<'EOF'
// === File: ThemeManager.swift
// Version: 1.4
// Date: 2025-08-30
// Description: Central theme store: manages selected Theme, background color live/persistent, card gradient.
// Author: K-Cim

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    // Selected base theme
    @Published var theme: Theme

    // Live background color (affects ThemedScreen)
    @Published var backgroundColor: Color

    // Keep defaults for reset
    private let defaultTheme: Theme
    private let defaultBackground: Color

    // Init
    init(default id: ThemeID) {
        // Base theme from presets
        var t = Theme.preset(id)

        // Load persisted card gradient (if any)
        let (start, end) = ThemePersistence.shared.loadCardGradient(
            defaultStart: t.cardStartOpacity,
            defaultEnd: t.cardEndOpacity
        )
        t.cardStartOpacity = start
        t.cardEndOpacity   = end

        self.theme = t
        self.defaultTheme = t

        // Background color: persisted or preset background
        let persistedBG = ThemePersistence.shared.loadBackgroundColor(default: t.background)
        self.backgroundColor = persistedBG
        self.defaultBackground = t.background
    }

    // MARK: - Background color controls

    func updateBackgroundColor(_ color: Color) {
        // Live update only (no persistence yet)
        self.backgroundColor = color
    }

    func applyBackgroundColor(_ color: Color) {
        self.backgroundColor = color
        ThemePersistence.shared.saveBackgroundColor(color)
    }

    func resetBackgroundColor() {
        self.backgroundColor = defaultBackground
        ThemePersistence.shared.saveBackgroundColor(defaultBackground)
    }

    // MARK: - Card gradient controls (ThemeConfigView)

    func liveUpdateCardGradient(startOpacity: Double, endOpacity: Double) {
        theme.cardStartOpacity = startOpacity
        theme.cardEndOpacity   = endOpacity
    }

    func applyCardGradient(startOpacity: Double, endOpacity: Double) {
        theme.cardStartOpacity = startOpacity
        theme.cardEndOpacity   = endOpacity
        ThemePersistence.shared.saveCardGradient(start: startOpacity, end: endOpacity)
    }

    func resetCardGradient() {
        theme.cardStartOpacity = defaultTheme.cardStartOpacity
        theme.cardEndOpacity   = defaultTheme.cardEndOpacity
        ThemePersistence.shared.saveCardGradient(start: theme.cardStartOpacity, end: theme.cardEndOpacity)
    }
}
EOF

# =========================================================
# 3) UI/Theme/ThemedModifiers.swift
# =========================================================
write_file "$BASE/UI/Theme/ThemedModifiers.swift" <<'EOF'
// === File: ThemedModifiers.swift
// Version: 1.2
// Date: 2025-08-30
// Description: Common themed helpers. ThemedScreen uses ThemeManager.backgroundColor live.
// Author: K-Cim

import SwiftUI

// MARK: - Themed Screen

struct ThemedScreen<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            content()
        }
    }
}

// MARK: - Themed Card

struct ThemedCard<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(themeManager.theme.cardStartOpacity),
                        Color.white.opacity(themeManager.theme.cardEndOpacity)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                    .strokeBorder(Color.white.opacity(0.08))
            )
            .overlay(
                VStack(alignment: .leading, spacing: 8) {
                    content()
                }
                .padding(16)
            )
    }
}

// MARK: - Foreground helpers

extension View {
    func themedForeground(_ theme: Theme) -> some View {
        self.foregroundStyle(theme.foreground)
    }

    func themedSecondary(_ theme: Theme) -> some View {
        self.foregroundStyle(theme.secondary)
    }

    // Optional: list background harmonization
    func themedListAppearance() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.clear)
    }
}
EOF

# =========================================================
# 4) UI/Components/ThemedBottomBar.swift
# =========================================================
write_file "$BASE/UI/Components/ThemedBottomBar.swift" <<'EOF'
// === File: ThemedBottomBar.swift
// Version: 1.3
// Date: 2025-08-30
// Description: Bottom bar with Home, Vault, Contacts, Settings; disables current tab and dims its color.
// Author: K-Cim

import SwiftUI

enum BottomTab: Hashable {
    case home, vault, contacts, settings
}

struct ThemedBottomBar: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let current: BottomTab

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            tabLabel(.home, system: "house", titleKey: "home") { HomeView() }
            Spacer(minLength: 0)
            tabLabel(.vault, system: "lock", titleKey: "vault") { VaultView() }
            Spacer(minLength: 0)
            tabLabel(.contacts, system: "person.2", titleKey: "contacts") { ContactsView() }
            Spacer(minLength: 0)
            tabLabel(.settings, system: "gearshape", titleKey: "settings") { SettingsMenuView() }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                .fill(LinearGradient(
                    colors: [
                        Color.white.opacity(themeManager.theme.cardStartOpacity),
                        Color.white.opacity(themeManager.theme.cardEndOpacity)
                    ],
                    startPoint: .leading, endPoint: .trailing
                ))
                .padding(.horizontal, 16)
        )
        .padding(.bottom, 16)
        .padding(.top, 4)
    }

    @ViewBuilder
    private func tabLabel<Destination: View>(
        _ tab: BottomTab,
        system: String,
        titleKey: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        let isCurrent = (tab == current)
        let fg = themeManager.theme.foreground
        let dim = themeManager.theme.secondary.opacity(0.85)

        if isCurrent {
            VStack(spacing: 4) {
                Image(systemName: system).font(.title2).foregroundStyle(dim)
                Text(NSLocalizedString(titleKey, comment: "")).font(.caption.bold()).foregroundStyle(dim)
            }
            .contentShape(Rectangle())
        } else {
            NavigationLink {
                destination()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: system).font(.title2).foregroundStyle(fg)
                    Text(NSLocalizedString(titleKey, comment: "")).font(.caption.bold()).foregroundStyle(fg)
                }
            }
        }
    }
}
EOF

# =========================================================
# 5) Core/Services/ThemePersistence.swift
# =========================================================
write_file "$BASE/Core/Services/ThemePersistence.swift" <<'EOF'
// === File: ThemePersistence.swift
// Version: 1.0
// Date: 2025-08-30
// Description: Save & load theme values (background color & card gradient) from UserDefaults.
// Author: K-Cim

import SwiftUI

final class ThemePersistence {
    static let shared = ThemePersistence()
    private init() {}

    private let bgR = "aetherion_bg_r"
    private let bgG = "aetherion_bg_g"
    private let bgB = "aetherion_bg_b"
    private let bgA = "aetherion_bg_a"

    private let cardStartKey = "aetherion_card_start_opacity"
    private let cardEndKey   = "aetherion_card_end_opacity"

    func saveBackgroundColor(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, &g, &b, &a) {
            UserDefaults.standard.set(r, forKey: bgR)
            UserDefaults.standard.set(g, forKey: bgG)
            UserDefaults.standard.set(b, forKey: bgB)
            UserDefaults.standard.set(a, forKey: bgA)
        }
    }

    func loadBackgroundColor(default fallback: Color = .black) -> Color {
        let ud = UserDefaults.standard
        guard ud.object(forKey: bgR) != nil,
              ud.object(forKey: bgG) != nil,
              ud.object(forKey: bgB) != nil else {
            return fallback
        }
        let r = ud.double(forKey: bgR)
        let g = ud.double(forKey: bgG)
        let b = ud.double(forKey: bgB)
        let a = ud.object(forKey: bgA) != nil ? ud.double(forKey: bgA) : 1.0
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func saveCardGradient(start: Double, end: Double) {
        UserDefaults.standard.set(start, forKey: cardStartKey)
        UserDefaults.standard.set(end,   forKey: cardEndKey)
    }

    func loadCardGradient(defaultStart: Double, defaultEnd: Double) -> (Double, Double) {
        let ud = UserDefaults.standard
        let start = ud.object(forKey: cardStartKey) != nil ? ud.double(forKey: cardStartKey) : defaultStart
        let end   = ud.object(forKey: cardEndKey)   != nil ? ud.double(forKey: cardEndKey)   : defaultEnd
        return (start, end)
    }
}
EOF

# =========================================================
# 6) Features/Settings/BackgroundColorConfigView.swift
# =========================================================
write_file "$BASE/Features/Settings/BackgroundColorConfigView.swift" <<'EOF'
// === File: BackgroundColorConfigView.swift
// Version: 1.0
// Date: 2025-08-30
// Description: Config screen for background color with live preview and Apply/Reset.
// Author: K-Cim

import SwiftUI

struct BackgroundColorConfigView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var tempColor: Color = ThemePersistence.shared.loadBackgroundColor(default: .black)
    @State private var savedColor: Color = ThemePersistence.shared.loadBackgroundColor(default: .black)

    var body: some View {
        ThemedScreen {
            VStack(spacing: 20) {
                Text("Couleur du fond")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .themedForeground(themeManager.theme)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                ThemedCard {
                    ColorPicker("Choisir une couleur",
                                selection: $tempColor,
                                supportsOpacity: true)
                        .onChange(of: tempColor) { newValue in
                            themeManager.updateBackgroundColor(newValue) // live preview
                        }
                }
                .padding(.horizontal, 16)

                ThemedCard {
                    RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                        .fill(tempColor)
                        .frame(height: 120)
                        .overlay(
                            Text("Aperçu")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.white)
                        )
                }
                .padding(.horizontal, 16)

                HStack(spacing: 12) {
                    Button("Reset") {
                        tempColor = savedColor
                        themeManager.updateBackgroundColor(savedColor)
                    }
                    .buttonStyle(.bordered)

                    Button("Apply") {
                        savedColor = tempColor
                        themeManager.applyBackgroundColor(tempColor)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 12)
                ThemedBottomBar(current: .settings)
            }
        }
    }
}

#Preview {
    BackgroundColorConfigView()
        .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
}
EOF

# =========================================================
# 7) (Optionnel) Features/Settings/SettingsMenuView.swift — ajoute le lien
#     → Décommente si tu veux écraser ta version actuelle.
# =========================================================
# write_file "$BASE/Features/Settings/SettingsMenuView.swift" <<'EOF'
# // === File: SettingsMenuView.swift
# // Version: 1.3
# // Date: 2025-08-30
# // Description: Settings hub; includes Theme + Background color entries.
# // Author: K-Cim
#
# import SwiftUI
#
# struct SettingsMenuView: View {
#     @EnvironmentObject private var themeManager: ThemeManager
#
#     var body: some View {
#         ThemedScreen {
#             VStack {
#                 ScrollView {
#                     VStack(alignment: .leading, spacing: 16) {
#                         Text("Paramètres")
#                             .font(.largeTitle.bold())
#                             .themedForeground(themeManager.theme)
#                             .padding(.horizontal, 16)
#
#                         NavigationLink { ThemeConfigView() } label: {
#                             ThemedCard {
#                                 HStack {
#                                     Image(systemName: "paintpalette")
#                                     Text("Thème").font(.headline.bold())
#                                     Spacer()
#                                     Image(systemName: "chevron.right")
#                                 }
#                             }
#                         }.padding(.horizontal, 16)
#
#                         NavigationLink { BackgroundColorConfigView() } label: {
#                             ThemedCard {
#                                 HStack {
#                                     Image(systemName: "drop.fill")
#                                     Text("Couleur du fond").font(.headline.bold())
#                                     Spacer()
#                                     Image(systemName: "chevron.right")
#                                 }
#                             }
#                         }.padding(.horizontal, 16)
#                     }
#                 }
#                 ThemedBottomBar(current: .settings)
#             }
#         }
#     }
# }
#
# #Preview {
#     NavigationStack {
#         SettingsMenuView()
#             .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
#     }
# }
# EOF

# =========================================================
# 8) Nettoyage d’anciennes versions conflictuelles (optionnel)
#    Si tu avais un "ThemeStyle.swift" ailleurs, commente/renomme-le.
# =========================================================
# Exemple de suppression automatique (décommente si tu es sûr) :
# find "$BASE" -type f -name "ThemeStyle.swift" -maxdepth 4 -print -exec mv {} {}.bak-$TS \;

ok "Tous les fichiers ont été écrits."

# =========================================================
# 9) Commit Git auto (optionnel)
# =========================================================
if [ "$AUTO_COMMIT" = "yes" ] && [ -d "$(dirname "$BASE")/.git" ]; then
  say "Commit Git automatique…"
  ( cd "$(dirname "$BASE")" && git add -A && git commit -m "chore(theme): apply theme pack $TS" ) \
    && ok "Commit créé."
else
  warn "AUTO_COMMIT=no (par défaut) ou repo .git non trouvé — aucun commit fait."
fi

ok "Terminé."
