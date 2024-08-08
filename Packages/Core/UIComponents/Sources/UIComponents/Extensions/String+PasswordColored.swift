import SwiftUI

extension String {

  public func passwordColored(text: String) -> Text {
    guard let textRange = self.range(of: text) else {
      return Text(self)
    }
    let beginning = String(self[self.startIndex..<textRange.lowerBound])
    let end = String(self[textRange.upperBound..<self.endIndex])
    let colored = text.reduce(Text(beginning)) { result, character in
      let coloredCharacter = Text("\(String(character))")
        .foregroundColor(Color(passwordChar: character))
      return result + coloredCharacter
    }
    return colored + Text(end)
  }
}
