import SwiftUI

public struct PartlyModifiedText: View {
        public let text: String
    let textModifier: (Text) -> Text
    let toBeModifiedModifier: (Text) -> Text
    let truncateString: Bool
    let range: Range<String.Index>

    public init(text: String,
                toBeModified: String,
                truncateString: Bool = false,
                textModifier: @escaping (Text) -> Text,
                toBeModifiedModifier: @escaping (Text) -> Text) {
        var tempText = text
        if truncateString {
                        var subtitleString = text.replacingOccurrences(of: "\n", with: " ")
            if let range = text.range(of: toBeModified, options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive]),
               (text[..<range.lowerBound].count + toBeModified.count) > 30 {
                subtitleString = "..." + text[range.lowerBound...]
            }
            tempText = subtitleString
        }
        self.text = tempText
        self.truncateString = truncateString
        range = tempText.range(of: toBeModified, options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive])
            ?? Range<String.Index>(uncheckedBounds: (lower: tempText.endIndex, upper: tempText.endIndex))
        self.textModifier = textModifier
        self.toBeModifiedModifier = toBeModifiedModifier
    }

    @ViewBuilder
    public var body: some View {
        textModifier(Text(text[..<range.lowerBound]))
            + toBeModifiedModifier(Text(text[range]))
            + textModifier(Text(text[range.upperBound...]))
    }
}

extension PartlyModifiedText {
    public init(text: String,
                toBeModified: String,
                truncateString: Bool = false,
                toBeModifiedModifier: @escaping (Text) -> Text) {
        self.init(text: text,
                  toBeModified: toBeModified,
                  truncateString: truncateString,
                  textModifier: { $0 },
                  toBeModifiedModifier: toBeModifiedModifier)
    }
}

extension PartlyModifiedText: Hashable {
    public static func == (lhs: PartlyModifiedText, rhs: PartlyModifiedText) -> Bool {
        lhs.text == rhs.text
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

struct PartlyModifiedText_Previews: PreviewProvider {
    static var previews: some View {
        PartlyModifiedText(text: "Hello World!", toBeModified: "World!") { $0.foregroundColor(.red)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
