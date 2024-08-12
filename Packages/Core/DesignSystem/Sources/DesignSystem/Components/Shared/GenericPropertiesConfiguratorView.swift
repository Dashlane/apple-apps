import SwiftUI

struct GenericPropertiesConfiguratorView<Content: View>: View {
  @State private var selectedMood = Mood.neutral
  @State private var selectedIntensity = Intensity.catchy
  @State private var selectedControlSize = ControlSize.regular
  @State private var isEnabled = true
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
        Text("Mini")
          .tag(ControlSize.mini)
        Text("Small")
          .tag(ControlSize.small)
        Text("Regular")
          .tag(ControlSize.regular)
        Text("Large")
          .tag(ControlSize.large)
      }

      Picker("UserInteraction", selection: $isEnabled.animation()) {
        Text("Enabled")
          .tag(true)
        Text("Disabled")
          .tag(false)
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
