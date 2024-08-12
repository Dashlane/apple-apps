import DesignSystem
import Foundation
import SwiftUI

struct TextAreasView: View {
  enum ViewConfiguration: String, CaseIterable {
    case lightAppearance
    case darkAppearance
    case smallestDynamicTypeSize
    case largeDynamicTypeSize
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["textAreasConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .lightAppearance:
      commonView
        .preferredColorScheme(.light)
    case .darkAppearance:
      commonView
        .preferredColorScheme(.dark)
    case .smallestDynamicTypeSize:
      commonView
        .dynamicTypeSize(.accessibility1)
    case .largeDynamicTypeSize:
      commonView
        .dynamicTypeSize(.xSmall)
    case .none:
      EmptyView()
    }
  }

  private var commonView: some View {
    VStack(spacing: 16) {
      TextArea(
        "Notes",
        text: .constant(String(repeating: "l", count: 120))
      )
      TextArea(
        "Mandatory Notes",
        text: .constant(String(repeating: "b", count: 120))
      ) {
        FieldTextualFeedback("Mandatory information.")
      }

      TextArea(
        "Great News!",
        text: .constant(String(repeating: "b", count: 120))
      ) {
        FieldTextualFeedback("This is a positive feedback!")
      }
      .style(.positive)
    }
    .padding()
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }
}
