import DesignSystem
import SwiftUI

struct ChipPreview: View {
    @State private var selectedColorScheme = ColorScheme.light
    @State private var selectedDynamicTypeSize = DynamicTypeSize.large

    var body: some View {
        List {
            Section("Settings") {
                Picker("Color Scheme", selection: $selectedColorScheme.animation()) {
                    Text("Light")
                        .tag(ColorScheme.light)
                    Text("Dark")
                        .tag(ColorScheme.dark)
                }
                Picker("Type Size", selection: $selectedDynamicTypeSize.animation()) {
                    Text("XS")
                        .tag(DynamicTypeSize.xSmall)
                    Text("S")
                        .tag(DynamicTypeSize.small)
                    Text("M")
                        .tag(DynamicTypeSize.medium)
                    Text("L")
                        .tag(DynamicTypeSize.large)
                    Text("XL")
                        .tag(DynamicTypeSize.xLarge)
                    Text("XXL")
                        .tag(DynamicTypeSize.xxLarge)
                    Text("XXXL")
                        .tag(DynamicTypeSize.xxxLarge)
                }
            }
            Section("Examples") {
                Chip("Streaming")
            }
        }
        .preferredColorScheme(selectedColorScheme)
        .dynamicTypeSize(selectedDynamicTypeSize)
    }
}
