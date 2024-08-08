#if canImport(UIKit)
  import SwiftUI

  struct TagsListPreview: View {
    @State private var elements: [TagsList.Element] = [
      "Business", "Marketing", "Shopping", "Finance", "Tech", "Travel", "Logistics",
    ]

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
        Section("Actions") {
          Button("Remove random element", action: removeRandomElement)
          Button("Add random element", action: addRandomElement)
        }
        Section("Examples") {
          TagsList(elements)
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        }
      }
      .preferredColorScheme(selectedColorScheme)
      .dynamicTypeSize(selectedDynamicTypeSize)
    }

    private func removeRandomElement() {
      withAnimation {
        let randomIndex = Int.random(in: 0...elements.count - 1)
        elements.remove(at: randomIndex)
      }
    }

    private func addRandomElement() {
      withAnimation {
        let randomIndex = Int.random(in: 0...elements.count - 1)
        let randomString = "\(Int.random(in: 0...100_000))"
        elements.insert(TagsList.Element(title: randomString), at: randomIndex)
      }
    }
  }
#endif
