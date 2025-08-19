import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct BreachPasswordGeneratorField: DetailField {
  public let title: String = ""
  let text: String

  @Environment(\.detailFieldType)
  public var fiberFieldType

  public init(text: String) {
    self.text = text
  }

  public var body: some View {
    PasswordText(text: text)
      .font(.body)
      .lineLimit(1)
      .foregroundStyle(Color.ds.text.neutral.catchy)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color.ds.container.agnostic.neutral.supershy)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  VStack {
    BreachPasswordGeneratorField(text: "_")
  }
}
