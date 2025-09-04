import Foundation
import SwiftUI

public struct PasswordText: View {
  var text: String
  let formatter: Formatter?

  public init(text: String, formatter: Formatter? = nil) {
    self.text = text
    self.formatter = formatter
  }

  public var body: some View {
    text.reduce(
      Text(""),
      { (currentText, char) -> Text in
        let tempText = Text("\(String(char), formatter: formatter)")
          .foregroundStyle(Color(passwordCharacter: char))
        return currentText + tempText
      }
    )
    .font(Font.system(.body, design: .monospaced))
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
