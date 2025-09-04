import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents

public struct DateDetailField: DetailField {
  public let title: String
  public let range: DateFieldRange?

  @Binding
  var date: Date?

  @Environment(\.detailMode)
  var detailMode

  public init(
    title: String,
    date: Binding<Date?>,
    range: DateFieldRange? = nil
  ) {
    self.title = title
    self._date = date
    self.range = range
  }

  public var body: some View {
    DS.Draft.DateField(
      title,
      date: $date,
      in: range
    ) {

    }
    .fieldEditionDisabled(!detailMode.isEditing, appearance: .discrete)
  }
}

extension DateDetailField {
  public init(
    title: String,
    date: Binding<Date?>
  ) {
    self.title = title
    self._date = date
    self.range = nil
  }
}

struct DateDetailField_Previews: PreviewProvider {

  static let date = Date()
  static var previews: some View {
    Form {
      DateDetailField(
        title: "Date",
        date: .constant(date),
        range: .future)
    }
  }
}
