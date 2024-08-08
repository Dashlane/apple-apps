import SwiftUI

struct SpaceSelectorSectionFeedbackKey: EnvironmentKey {
  static var defaultValue: String? = ""
}

extension EnvironmentValues {
  var spaceSelectorSectionFeedback: String? {
    get { self[SpaceSelectorSectionFeedbackKey.self] }
    set { self[SpaceSelectorSectionFeedbackKey.self] = newValue }
  }
}

extension View {
  func spaceSelectorSectionFeedback(_ message: String) -> some View {
    self.environment(\.spaceSelectorSectionFeedback, message)
  }
}
