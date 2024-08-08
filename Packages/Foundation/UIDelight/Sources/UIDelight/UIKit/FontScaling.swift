#if canImport(UIKit)
  import UIKit

  public struct FontScaling {
    public static func scaledFont(font: UIFont, textStyle: UIFont.TextStyle = .body) -> UIFont {
      let fontMetrics = UIFontMetrics(forTextStyle: textStyle)

      return fontMetrics.scaledFont(for: font)
    }
  }
#endif
