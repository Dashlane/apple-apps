import Foundation
import SwiftUI

public struct ListItemCreditCardLabelDescription: View {
  private let icon: Image
  private let number: String
  private let expirationDate: Date

  public init(icon: Image, number: String, expirationDate: Date) {
    self.icon = icon
    self.number = number
    self.expirationDate = expirationDate
  }

  public var body: some View {
    Label(
      title: {
        HStack(spacing: 8) {
          Text(verbatim: "••••\(number.suffix(4))")
            .accessibilityLabel(Text(verbatim: String(number.suffix(4))))
          Text(expirationDate, format: .dateTime.month(.twoDigits).year(.twoDigits))
            .monospacedDigit()
        }
      },
      icon: { icon.resizable() }
    )
    .labelStyle(ListItemLabelDescriptionLabelStyle())
  }
}

#Preview("Default") {
  ListItemCreditCardLabelDescription(
    icon: .ds.fingerprint.outlined,
    number: "123456789123",
    expirationDate: .now
  )
  .environment(\.locale, .init(identifier: "fr"))
}

#Preview("Japanese") {
  ListItemCreditCardLabelDescription(
    icon: .ds.fingerprint.outlined,
    number: "123456789123",
    expirationDate: .now
  )
  .environment(\.locale, .init(identifier: "ja"))
}
