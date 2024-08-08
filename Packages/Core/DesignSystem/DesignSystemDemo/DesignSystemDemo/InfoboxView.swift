import DesignSystem
import SwiftUI

struct InfoboxView: View {
  enum ViewConfiguration: String, CaseIterable {
    case moodsLight
    case moodsDark
    case standardConfigurations
    case overrides
    case smallestDynamicTypeClass
    case standardDynamicTypeClass
    case largestDynamicTypeClass
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["infoboxConfiguration"] else {
      return nil
    }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    ScrollView {
      switch viewConfiguration {
      case .moodsLight:
        moodsPreview
          .environment(\.colorScheme, .light)
      case .moodsDark:
        moodsPreview
          .environment(\.colorScheme, .dark)
          .background(.black)
      case .standardConfigurations:
        VStack {
          ForEach([ControlSize.regular, .large], id: \.self) { controlSize in
            Infobox("Title")
              .controlSize(controlSize)
          }
          Infobox("Title") {
            Button("Primary 1") {}
          }
          Infobox("Title") {
            Button("Primary 2") {}
            Button("Secondary 1") {}
          }

          ForEach([ControlSize.regular, .large], id: \.self) { controlSize in
            Infobox("Title", description: "Description")
              .controlSize(controlSize)
          }

          Infobox("Title") {
            Button("Primary 3") {}
            Button("Secondary 2") {}
          }

          Infobox("Title", description: "Description") {
            Button("Primary 4") {}
            Button("Secondary 3") {}
          }
        }
        .padding()
      case .overrides:
        Infobox("Title", description: "Description") {
          Button("Primary 5") {}
            .style(intensity: .quiet)
        }
        .padding()
      case .smallestDynamicTypeClass:
        dynamicTypePreview
          .environment(\.sizeCategory, .extraSmall)
      case .standardDynamicTypeClass:
        dynamicTypePreview
      case .largestDynamicTypeClass:
        dynamicTypePreview
          .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
      case .none:
        EmptyView()
      }
    }
  }

  private var moodsPreview: some View {
    VStack {
      ForEach(Mood.allCases) { mood in
        Infobox("Title \(mood)", description: "Description \(mood)") {
          Button(action: {}, title: "Primary \(mood)")
          Button(action: {}, title: "Secondary \(mood)")
        }
        .style(mood: mood)
      }
    }
    .padding()
  }

  private var dynamicTypePreview: some View {
    VStack {
      Infobox(
        "A precious additional information",
        description: "More details about what it impacts and what to do about it."
      ) {
        Button("Primary - a very long title") {}
        Button("Secondary - a very long title") {}
      }
      .style(mood: .danger)
    }
    .padding()
  }
}

struct InfoboxView_Previews: PreviewProvider {
  static var previews: some View {
    InfoboxView()
  }
}
