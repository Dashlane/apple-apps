import SwiftUI

extension EnvironmentValues {
  @Entry var displayLabelAsOverlay: Bool = false
  @Entry var isFieldEditing: Bool = false
  @Entry var fieldLabelHiddenOnFocus: Bool = false
  @Entry var defaultFieldActionsHidden: Bool = false
  @Entry var fieldRequired: Bool = false
  @Entry var fieldEditionDisabled: Bool = false
}

extension View {
  public func fieldLabelHiddenOnFocus(_ hidden: Bool = true) -> some View {
    environment(\.fieldLabelHiddenOnFocus, hidden)
  }

  public func defaultFieldActionsHidden(_ hidden: Bool = true) -> some View {
    environment(\.defaultFieldActionsHidden, hidden)
  }

  public func fieldRequired(_ required: Bool = true) -> some View {
    environment(\.fieldRequired, required)
  }

  public func fieldEditionDisabled(
    _ disabled: Bool = true,
    appearance: FieldDisabledEditionAppearance = .emphasized
  ) -> some View {
    self
      .environment(\.fieldEditionDisabled, disabled)
      .environment(\.fieldDisabledEditionAppearance, appearance)
  }
}
