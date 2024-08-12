import DesignSystem
import SwiftUI

struct TogglesView: View {
  enum ViewConfiguration: String, CaseIterable {
    case lightAppearance
    case darkAppearance
    case smallestDynamicTypeClass
    case largestDynamicTypeClass
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["togglesConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .lightAppearance:
      contentView
        .preferredColorScheme(.light)
    case .darkAppearance:
      contentView
        .preferredColorScheme(.dark)
    case .smallestDynamicTypeClass:
      contentView
        .preferredColorScheme(.light)
        .dynamicTypeSize(.xSmall)
    case .largestDynamicTypeClass:
      contentView
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility5)
    case .none:
      EmptyView()
    }
  }

  private var contentView: some View {
    List {
      DS.Toggle("This is a short option", isOn: .constant(true))
      DS.Toggle(
        "This is a very long option that will spawn on multiple lines",
        isOn: .constant(true)
      )
      DS.Toggle(
        "This is an extreme option\n that will spawn\n on 3 lines",
        isOn: .constant(true)
      )
    }
  }
}

struct TogglesView_Previews: PreviewProvider {
  static var previews: some View {
    TogglesView()
  }
}
