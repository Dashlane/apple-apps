import SwiftUI

struct ButtonsConfiguratorView<Content: View>: View {
    @State private var selectedMood = Mood.neutral
    @State private var selectedIntensity = Intensity.catchy
    @State private var selectedControlSize = ControlSize.small
    @State private var isEnabled = true
    @State private var selectedLayout = RoundedButtonLayout.fit
    @State private var selectedColorScheme = ColorScheme.light
    @State private var selectedDynamicTypeSize = DynamicTypeSize.large

    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                pickers
                content()
                    .style(mood: selectedMood, intensity: selectedIntensity)
                    .controlSize(selectedControlSize)
                    .roundedButtonLayout(selectedLayout)
                    .disabled(!isEnabled)
                    .colorScheme(selectedColorScheme)
                    .dynamicTypeSize(selectedDynamicTypeSize)
            }
        }
    }

    @ViewBuilder
    private var pickers: some View {
        VStack {
            Picker("Mood", selection: $selectedMood.animation()) {
                ForEach(Mood.allCases) { mood in
                    Text(mood.rawValue.capitalized)
                }
            }

            Picker("Intensity", selection: $selectedIntensity.animation()) {
                ForEach(Intensity.allCases) { intensity in
                    Text(intensity.rawValue.capitalized)
                }
            }

            Picker("ControlSize", selection: $selectedControlSize.animation(.spring(response: 0.4))) {
                Text("Small")
                    .tag(ControlSize.small)
                Text("Regular")
                    .tag(ControlSize.regular)
            }

            Picker("UserInteraction", selection: $isEnabled.animation()) {
                Text("Enabled")
                    .tag(true)
                Text("Disabled")
                    .tag(false)
            }

            Picker("Layout", selection: $selectedLayout.animation(.spring(response: 0.4))) {
                Text("Fit")
                    .tag(RoundedButtonLayout.fit)
                Text("Fill")
                    .tag(RoundedButtonLayout.fill)
            }

            Picker("ColorScheme", selection: $selectedColorScheme.animation()) {
                Text("Light")
                    .tag(ColorScheme.light)
                Text("Dark")
                    .tag(ColorScheme.dark)
            }

            Picker("RegularDynamicTypeSize", selection: $selectedDynamicTypeSize.animation()) {
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

            Picker("RegularDynamicTypeSize", selection: $selectedDynamicTypeSize.animation()) {
                Text("A1")
                    .tag(DynamicTypeSize.accessibility1)
                Text("A2")
                    .tag(DynamicTypeSize.accessibility2)
                Text("A3")
                    .tag(DynamicTypeSize.accessibility3)
                Text("A4")
                    .tag(DynamicTypeSize.accessibility4)
                Text("A5")
                    .tag(DynamicTypeSize.accessibility5)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct StylesButtonPreview: View {

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Mood.allCases) { mood in
                VStack(spacing: 10) {
                    ForEach(Intensity.allCases) { intensity in
                        RoundedButton("Button") {}
                            .style(mood: mood, intensity: intensity)
                        RoundedButton("Button") {}
                            .style(mood: mood, intensity: intensity)
                            .disabled(true)
                    }
                }
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Styles")
        .previewDevice("iPad mini (6th generation)")
    }
}

struct ConfigurationButtonPreview: View {
    var body: some View {
        ButtonsConfiguratorView {
            VStack {
                RoundedButton(icon: .ds.feedback.info.filled) {}

                RoundedButton("Button") {}

                RoundedButton("Button", icon: .ds.feedback.info.filled) {}

                RoundedButton("Button", icon: .ds.feedback.info.filled) {}
                    .iconAlignment(.trailing)

                RoundedButton("This is very long label which spawns on multiple lines") {}

                HStack(spacing: 8) {
                    ProgressButtonPreview()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.ds.background.alternate)
            )
        }
        .padding()
        .padding(.top, 30)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Configurations")
    }
}

struct ProgressButtonPreview: View {
    @State private var displayProgressIndicator = false

    var body: some View {
        RoundedButton("Toggle", action: { displayProgressIndicator.toggle() })
            .roundedButtonDisplayProgressIndicator(displayProgressIndicator)
    }
}

struct Previews: PreviewProvider {

    static var previews: some View {
        ConfigurationButtonPreview()
        StylesButtonPreview()
    }
}
