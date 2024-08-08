import SwiftUI

struct ButtonDisplayProgressIndicatorKey: EnvironmentKey {
  static var defaultValue = false
}

extension EnvironmentValues {
  var buttonDisplayProgressIndicator: Bool {
    get { self[ButtonDisplayProgressIndicatorKey.self] }
    set { self[ButtonDisplayProgressIndicatorKey.self] = newValue }
  }
}

extension View {
  public func buttonDisplayProgressIndicator(_ display: Bool) -> some View {
    self.environment(\.buttonDisplayProgressIndicator, display)
  }
}

struct ButtonProgressIndicator_Library: LibraryContentProvider {

  @LibraryContentBuilder
  func modifiers(base: some View) -> [LibraryItem] {
    LibraryItem(
      base.buttonDisplayProgressIndicator(true),
      title: "Button Progress Indicator",
      category: .effect
    )
  }
}
