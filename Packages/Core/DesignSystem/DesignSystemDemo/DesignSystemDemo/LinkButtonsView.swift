import DesignSystem
import Foundation
import SwiftUI

struct LinkButtonsView: View {
  enum ViewConfiguration: String, CaseIterable {
    case lightAppearance
    case darkAppearance
    case smallestDynamicTypeSize
    case largestDynamicTypeSize
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["linkButtonsConfiguration"]
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
        .dynamicTypeSize(.xSmall)
    case .largestDynamicTypeSize:
      commonView
        .dynamicTypeSize(.accessibility1)
    case .none:
      EmptyView()
    }
  }

  private var commonView: some View {
    VStack {
      ForEach(Mood.allCases) { mood in
        VStack {
          Button("Learn More") {}
            .buttonStyle(.internalLink)
          Button("Terms & Conditions") {}
            .buttonStyle(.externalLink)
            .controlSize(.mini)
        }
        .style(mood: mood)
      }
    }
  }
}

struct LinkButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    LinkButtonsView()
  }
}
