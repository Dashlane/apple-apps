import SwiftUI

struct BadgePreview: View {
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
            ForEach(Mood.allCases) { mood in
                Section(mood.rawValue) {
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(Intensity.allCases) { intensity in
                                Badge(intensity.rawValue)
                                    .style(mood: mood, intensity: intensity)
                            }
                        }
                        HStack {
                            ForEach(Intensity.allCases) { intensity in
                                Badge(intensity.rawValue, icon: .ds.lock.outlined)
                                    .style(mood: mood, intensity: intensity)
                            }
                        }
                        HStack {
                            ForEach(Intensity.allCases) { intensity in
                                Badge(intensity.rawValue, icon: .ds.lock.outlined)
                                    .style(mood: mood, intensity: intensity)
                                    .iconAlignment(.trailing)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Section("Examples") {
                HStack {
                    Text("_")
                    Badge("Expired")
                        .style(mood: .danger, intensity: .quiet)
                }
                HStack {
                    Text("_")
                    Badge("Owner")
                        .style(mood: .brand, intensity: .catchy)
                }
            }
        }
        .preferredColorScheme(selectedColorScheme)
        .dynamicTypeSize(selectedDynamicTypeSize)
    }
}
