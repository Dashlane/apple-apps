import SwiftUI

enum FieldLabelPersistencyDisabledKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var fieldLabelPersistencyDisabled: Bool {
    get { self[FieldLabelPersistencyDisabledKey.self] }
    set { self[FieldLabelPersistencyDisabledKey.self] = newValue }
  }
}

extension View {
  public func fieldLabelPersistencyDisabled(_ disabled: Bool = true) -> some View {
    environment(\.fieldLabelPersistencyDisabled, disabled)
  }
}
