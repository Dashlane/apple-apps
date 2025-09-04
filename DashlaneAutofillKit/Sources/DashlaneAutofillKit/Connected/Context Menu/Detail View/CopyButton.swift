import CoreLocalization
import DesignSystem
import SwiftUI

struct CopyButton: View {
  let copy: (String) -> Void
  let date: Date?
  let formatter: DateFormatter

  @Environment(\.toast) var toast

  init(
    copy: @escaping (String) -> Void,
    date: Date?,
    formatter: DateFormatter = DateFormatter.birthDateFormatter
  ) {
    self.copy = copy
    self.date = date
    self.formatter = formatter
  }

  var body: some View {
    DS.FieldAction.CopyContent {
      copy(formatter.string(from: date ?? Date()))
      toast(CoreL10n.kwCopied, image: .ds.action.copy.outlined)
    }
    .buttonStyle(.designSystem(.iconOnly))
    .style(intensity: .supershy)
    .padding(.trailing, -16)
  }
}

#Preview {
  CopyButton(copy: { _ in }, date: Date())
}
