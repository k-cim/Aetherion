// === File: ColoredSlider.swift
// Date: 2025-09-05
// Description: Custom slider fully colorized with theme tint.

import SwiftUI

struct ColoredSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let tint: Color
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let knobSize: CGFloat = 20
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let knobX = progress * (width - knobSize)
            
            ZStack(alignment: .leading) {
                // track
                Capsule()
                    .fill(tint.opacity(0.3))
                    .frame(height: 6)
                
                // filled track
                Capsule()
                    .fill(tint)
                    .frame(width: knobX + knobSize/2, height: 6)
                
                // knob
                Circle()
                    .fill(tint)
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: knobX)
                    .gesture(
                        DragGesture()
                            .onChanged { g in
                                let pct = min(max(0, g.location.x / width), 1)
                                let newValue = range.lowerBound + Double(pct) * (range.upperBound - range.lowerBound)
                                value = (newValue / step).rounded() * step
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}
