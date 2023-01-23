#if !os(macOS)
import UIKit

extension NSMutableAttributedString {
    public func addAttributes(_ attributes: [NSAttributedString.Key: Any], toString string: String) {
        var range = mutableString.range(of: string)
        while range.location != NSNotFound {
            addAttributes(attributes, range: range)
            range = mutableString.range(of: string, after: range)
        }
    }

    public func formattedHtml(htmlFont: UIFont, color: UIColor) -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired, using: { value, range, _ in
            guard let currentFont = value as? UIFont else {
                return
            }
            let traits = currentFont.fontDescriptor.symbolicTraits
            if let fontDescriptor = htmlFont.fontDescriptor.withSymbolicTraits(traits) {
                let mergedFont = UIFont(descriptor: fontDescriptor, size: 0)
                addAttribute(.font, value: mergedFont, range: range)
            }
        })
        addAttribute(.foregroundColor, value: color, range: range)
        return NSAttributedString(attributedString: self)
    }

                public convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue]
        guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString: attributedString)
    }
}

private extension NSMutableString {
    func range(of string: String, after previousRange: NSRange) -> NSRange {
        return range(of: string, range: NSRange(location: previousRange.upperBound, length: length - previousRange.upperBound))

    }
}
#endif
