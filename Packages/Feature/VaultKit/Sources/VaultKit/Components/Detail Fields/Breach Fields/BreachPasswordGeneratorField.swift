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
      .foregroundColor(.ds.text.neutral.catchy)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color.ds.container.agnostic.neutral.supershy)
  }
}

struct BreachPasswordGeneratorField_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      VStack {
        BreachPasswordGeneratorField(text: "_")
      }
    }.previewLayout(.sizeThatFits)
  }
}
