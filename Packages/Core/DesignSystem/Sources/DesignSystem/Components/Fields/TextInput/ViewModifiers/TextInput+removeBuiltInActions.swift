import Foundation
import SwiftUI

enum TextInputBuiltInActionsRemovedKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var textInputBuiltInActionsRemoved: Bool {
    get { self[TextInputBuiltInActionsRemovedKey.self] }
    set { self[TextInputBuiltInActionsRemovedKey.self] = newValue }
  }
}

extension View {
  public func textInputRemoveBuiltInActions(_ remove: Bool = true) -> some View {
    environment(\.textInputBuiltInActionsRemoved, remove)
  }
}
