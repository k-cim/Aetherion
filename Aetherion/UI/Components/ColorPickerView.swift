// === File: SystemColorPicker.swift
// Date: 2025-08-30
// Description: Simple, safe color picker using SwiftUI's native ColorPicker.
// Author: K-Cim

import SwiftUI

struct SystemColorPicker: View {
    @Binding var color: Color
    var supportsAlpha: Bool = true
    var title: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.headline.bold())
            }

            // ColorPicker natif Apple (spectre + alpha)
            ColorPicker("", selection: $color, supportsOpacity: supportsAlpha)
                .labelsHidden()
        }
    }
}
