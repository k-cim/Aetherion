# === File: UI/Components/ColoredSlider.swift
# Date: 2025-09-05
# Description: Slider custom, entièrement colorisé avec une teinte.

## STRUCT ColoredSlider : View
- Scope: Public
- Type: SwiftUI View
- Rôle: Remplacer le Slider natif, permet couleur et style perso.

### Vars
- @Binding var value: Double → liaison externe (valeur du slider, global côté appelant)
- let range: ClosedRange<Double> → bornes min/max (local)
- let step: Double → pas d’incrémentation (local)
- let tint: Color → couleur appliquée (local)

### Body
- GeometryReader (width)
  - Calcul progress (0...1) → knobX
  - ZStack:
    - Capsule() track → tint.opacity(0.3)
    - Capsule() progress → tint
    - Circle() knob → tint, dragable
      - DragGesture → met à jour value selon position + step arrondi

### Externes utilisés
- SwiftUI (GeometryReader, Capsule, Circle, DragGesture)

### Entrées / Sortie
- Entrées: value:Binding<Double>, range:ClosedRange<Double>, step:Double, tint:Color
- Sortie: some View (slider custom)

### Exemple
```swift
ColoredSlider(value: $opacity, range: 0...1, step: 0.01, tint: .blue)
    .frame(width: 200)
