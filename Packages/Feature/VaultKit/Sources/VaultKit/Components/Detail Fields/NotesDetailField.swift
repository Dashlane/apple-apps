import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

public struct NotesDetailField: DetailField {

  public let title: String

  @Binding
  var text: String

  @FocusState
  var isEditing

  @Environment(\.detailMode)
  var detailMode

  @Environment(\.detailFieldType)
  public var fiberFieldType

  public init(
    title: String,
    text: Binding<String>
  ) {
    self.title = title
    self._text = text
  }

  public var body: some View {
    DS.TextArea(
      title,
      text: $text
    )
    .focused($isEditing)
    .editionDisabled(!detailMode.isEditing, appearance: .discrete)
  }
}
