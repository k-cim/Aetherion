// === File: UI/Components/ThemedSlider.swift
// Version: 2.1
// Date: 2025-09-14
// Description: Slider thémé, accessible et robuste (tap-to-seek, drag, step arrondi, RTL).
//              Remplace "ColoredSlider" avec compat ascendante via typealias.
// Author: K-Cim

import SwiftUI

struct ThemedSlider: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.layoutDirection) private var layoutDirection

    // Valeur et contraintes
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1

    // Apparence / comportement
    var trackHeight: CGFloat = 6
    var knobSize: CGFloat = 20
    var isEnabled: Bool = true
    var allowTapToSeek: Bool = true
    /// Optionnel : couleur de teinte (sinon `theme.controlTint`)
    var tintOverride: Color? = nil
    var onEditingChanged: (Bool) -> Void = { _ in }

    // État d’édition
    @State private var isEditing = false

    // Utilitaires
    private var t: Theme { themeManager.theme }
    private var tint: Color { tintOverride ?? t.controlTint }

    // MARK: - Inits compatibles
    init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1,
        trackHeight: CGFloat = 6,
        knobSize: CGFloat = 20,
        isEnabled: Bool = true,
        allowTapToSeek: Bool = true,
        tint: Color? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.trackHeight = trackHeight
        self.knobSize = knobSize
        self.isEnabled = isEnabled
        self.allowTapToSeek = allowTapToSeek
        self.tintOverride = tint
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width) // évite division par zéro
            let clamped = value.clamped(to: range)
            let p = progress(for: clamped)                // 0...1
            let pDir = directional(p)                     // RTL ready
            let knobX = pDir * (width - knobSize)
            let filled = knobX + knobSize/2

            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(tint.opacity(0.25))
                    .frame(height: trackHeight)

                // Filled
                Capsule()
                    .fill(tint)
                    .frame(width: filled, height: trackHeight)

                // Knob
                Circle()
                    .fill(tint)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .overlay(
                        Circle().strokeBorder(Color.white.opacity(0.15))
                    )
                    .offset(x: knobX)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                guard isEnabled else { return }
                                if !isEditing {
                                    isEditing = true
                                    onEditingChanged(true)
                                }
                                let x = g.location.x.clamped(to: 0...width)
                                let pRaw = x / width
                                setProgress(pRaw, width: width)
                            }
                            .onEnded { g in
                                guard isEnabled else { return }
                                finishEdit(geoWidth: width, x: g.location.x)
                            }
                    )
            }
            .frame(height: max(knobSize, trackHeight))
            .contentShape(Rectangle()) // pour capturer les taps sur toute la zone
            // Tap-to-seek avec position (TapGesture ne donne pas la position)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { g in
                        guard isEnabled, allowTapToSeek, !isEditing else { return }
                        let x = g.location.x.clamped(to: 0...width)
                        withAnimation(.easeOut(duration: 0.15)) {
                            setProgress(x / width, width: width, commit: true)
                        }
                    }
            )
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.easeOut(duration: 0.12), value: value)
            .animation(.easeOut(duration: 0.12), value: isEditing)
            .accessibilityElement()
            .accessibilityLabel("Réglage")
            .accessibilityValue(accessibilityValueText)
            .accessibilityAdjustableAction { dir in
                guard isEnabled else { return }
                switch dir {
                case .increment: value = snap(value + step)
                case .decrement: value = snap(value - step)
                @unknown default: break
                }
                value = value.clamped(to: range)
            }
        }
        .frame(height: max(knobSize, trackHeight))
    }

    // MARK: - Helpers

    private func progress(for v: Double) -> CGFloat {
        let total = range.upperBound - range.lowerBound
        guard total > 0 else { return 0 }
        return CGFloat((v - range.lowerBound) / total).clamped(to: 0...1)
    }

    /// Inverse la progression en RTL.
    private func directional(_ p: CGFloat) -> CGFloat {
        layoutDirection == .rightToLeft ? (1 - p) : p
    }

    private func setProgress(_ raw: CGFloat, width: CGFloat, commit: Bool = false) {
        let p = raw.clamped(to: 0...1)
        let base = range.lowerBound + Double(p) * (range.upperBound - range.lowerBound)
        let snapped = snap(base)
        value = snapped.clamped(to: range)
        if commit, isEditing {
            isEditing = false
            onEditingChanged(false)
        }
    }

    private func snap(_ v: Double) -> Double {
        guard step > 0 else { return v }
        let n = ((v - range.lowerBound) / step).rounded()
        return range.lowerBound + n * step
    }

    private func finishEdit(geoWidth: CGFloat, x: CGFloat) {
        let pRaw = (x / geoWidth).clamped(to: 0...1)
        setProgress(pRaw, width: geoWidth, commit: true)
    }

    private var accessibilityValueText: String {
        let span = range.upperBound - range.lowerBound
        if span == 100 || span == 1 {
            let pct = Int(((value - range.lowerBound) / span * 100).rounded())
            return "\(pct) %"
        } else {
            return "\(Int(value.rounded()))"
        }
    }
}

// MARK: - Compat ascendante
typealias ColoredSlider = ThemedSlider

// MARK: - Utils

private extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self {
        Swift.min(Swift.max(self, r.lowerBound), r.upperBound)
    }
}

private extension CGFloat {
    func clamped(to r: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, r.lowerBound), r.upperBound)
    }
}
