import Foundation

public struct AlertSection {

    public struct Title {
        public internal(set) var data: String

        init(_ string: String) {
            self.data = string
        }
    }

    public internal(set) var title: Title
    public internal(set) var contents: [String] = []

    public func string() -> String {
        return String(format: title.data, arguments: contents as [CVarArg])
    }

    public func attributedString(withContentAttributes attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {

        let mutableAttributedString = NSMutableAttributedString(string: self.string())
        let nsstring = mutableAttributedString.string as NSString

        for content in contents {
            let contentRange = nsstring.range(of: content)
            guard contentRange.isValidIn(string: nsstring) else { break }
            mutableAttributedString.addAttributes(attributes, range: contentRange)
        }

        return mutableAttributedString
    }

    public func attributedString(withContentJoinedBy separator: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {

        let content = contents.joined(separator: ", ")
        let mutableAttributedString = NSMutableAttributedString(string: String(format: title.data, content))
        let nsstring = mutableAttributedString.string as NSString

        let contentRange = nsstring.range(of: content)
        if contentRange.isValidIn(string: nsstring) {
            mutableAttributedString.addAttributes(attributes, range: contentRange)
        }

        return mutableAttributedString
    }

    public func attributedString(withContentAttributes attributes: [NSAttributedString.Key: Any], splittedBy delimiter: String) -> NSAttributedString {

                                var reversedContents: [String] = contents.reversed()
        let components = title.data.components(separatedBy: delimiter)
        let filledTitle = components.reduce("") { (result, str) -> String in
            guard let content = reversedContents.popLast() else {
                return result
            }
            return result.appending(str.appending(content))
        }

        let mutableAttributedString = NSMutableAttributedString(string: filledTitle)
        let nsstring = mutableAttributedString.string as NSString

        for content in contents {
            let contentRange = nsstring.range(of: content)
            guard contentRange.isValidIn(string: nsstring) else { break }
            mutableAttributedString.addAttributes(attributes, range: contentRange)
        }

        return mutableAttributedString
    }
}

private extension NSRange {
    func isValidIn(string: NSString) -> Bool {
        return self.location != NSNotFound && self.location + self.length <= string.length
    }
}
