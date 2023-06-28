import Foundation

private struct ValueContainer<T: Decodable>: Decodable {
    let value: T
}

private struct FontContainer: Decodable {
    struct FontAttributes: Decodable {
        let format: String
        let fontFamily: String
        let url: URL
        let fontPostScriptName: String
    }

    struct UnitMeasure: Decodable {
        let unit: String
        let measure: Double
    }

    enum TextTransform: String, Decodable {
        case uppercase
    }

    enum TextDecoration: String, Decodable {
        case underline
    }

    let font: ValueContainer<FontAttributes>
    let fontSize: ValueContainer<UnitMeasure>
    let lineHeight: ValueContainer<UnitMeasure>
    let letterSpacing: ValueContainer<UnitMeasure>?
    let textTransform: TextTransform?
    let textDecoration: [TextDecoration]?
}

struct SpecifyTypographyToken: Decodable {
    enum TextStyleDecodingError: Error {
        case wrongItemType
    }

    enum DecodingError: Error {
        case invalidTextStylePrefixName
    }

        let name: String
        let format: String
        let fontFamily: String
        let fontSize: Double
        let fontPostScriptName: String
        let nativeStyleMatch: String
            let lineHeight: Double
        let letterSpacing: Double?
        let textTransform: String?
        let textDecorations: [String]
        let leading: String
        let font: Data?

    private let fetchFontTask: Task<Data, Error>?

        init(from decoder: Decoder) throws {
        struct RawRepresentation: Decodable {
            let name: String
            let value: FontContainer
            let description: String
        }

        let container = try decoder.singleValueContainer()
        let rawRepresentation = try container.decode(RawRepresentation.self)

        guard rawRepresentation.name.prefix(1) == "🍎"
        else { throw DecodingError.invalidTextStylePrefixName }

        name = String(rawRepresentation.name.dropFirst(2))
        format = rawRepresentation.value.font.value.format
        fontFamily = rawRepresentation.value.font.value.fontFamily
        fontSize = rawRepresentation.value.fontSize.value.measure
        fontPostScriptName = rawRepresentation.value.font.value.fontPostScriptName
        lineHeight = rawRepresentation.value.lineHeight.value.measure
        letterSpacing = rawRepresentation.value.letterSpacing?.value.measure
        textTransform = rawRepresentation.value.textTransform?.rawValue
        textDecorations = rawRepresentation.value.textDecoration?.map(\.rawValue) ?? []
        font = nil

                let description = rawRepresentation.description

                        var nativeStyleMatch = "body"
                        var leading = "standard"

        if !description.isEmpty,
           let tokenLowerIndex = description.range(of: "{")?.upperBound,
           let tokenUpperIndex = description.range(of: "}")?.lowerBound {
                        let tokens = description[tokenLowerIndex..<tokenUpperIndex].components(separatedBy: ",")
            for token in tokens {
                let destructuredToken = token.components(separatedBy: ":")
                guard let tokenName = destructuredToken.first,
                      let tokenValue = destructuredToken.last,
                      tokenName != tokenValue
                else { continue }

                switch tokenName.trimmingCharacters(in: .whitespaces) {
                                case "apple_native":
                    nativeStyleMatch = tokenValue.trimmingCharacters(in: .whitespaces)
                case "leading":
                    leading = tokenValue.trimmingCharacters(in: .whitespaces)
                default:
                    break
                }
            }
        }

        self.nativeStyleMatch = nativeStyleMatch
        self.leading = leading

        let fontFileURL = rawRepresentation.value.font.value.url
        fetchFontTask = Task {
            let (data, _) = try await URLSession.shared.data(from: fontFileURL)
            return data
        }
    }

    private init(
        name: String,
        format: String,
        fontFamily: String,
        fontSize: Double,
        fontPostScriptName: String,
        nativeStyleMatch: String,
        lineHeight: Double,
        letterSpacing: Double?,
        textTransform: String?,
        textDecorations: [String],
        leading: String,
        font: Data
    ) {
        self.name = name
        self.format = format
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontPostScriptName = fontPostScriptName
        self.nativeStyleMatch = nativeStyleMatch
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.textTransform = textTransform
        self.textDecorations = textDecorations
        self.font = font
        self.leading = leading
        self.fetchFontTask = nil
    }

        var usesCustomFont: Bool {
        !usesSystemFont
    }

    var usesSystemFont: Bool {
        fontPostScriptName.contains("SFPro") || fontPostScriptName.contains("SFMono")
    }

    var isUppercased: Bool {
        textTransform == "uppercase"
    }

    var isUnderlined: Bool {
        Set(textDecorations).contains("underline")
    }

    var fontDesign: String {
        guard fontPostScriptName.contains("SFMono") else { return "default" }
        return "monospaced"
    }

    var fontFamilyPath: String? {
        guard usesCustomFont else { return nil }
        let familyName = fontFamily.replacingOccurrences(of: " ", with: "")
        return "\(familyName).\(fontWeight)"
    }

    var fontWeight: String {
        let familyName = fontFamily.replacingOccurrences(of: " ", with: "")
        let suffix = String(fontPostScriptName.dropFirst(familyName.count)).lowercased()
        return suffix.replacingOccurrences(of: "-", with: "")
    }

        func withFont() async throws -> SpecifyTypographyToken {
        guard let fetchFontTask else { return self }
        return try await .init(
            name: name,
            format: format,
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontPostScriptName: fontPostScriptName,
            nativeStyleMatch: nativeStyleMatch,
            lineHeight: lineHeight,
            letterSpacing: letterSpacing,
            textTransform: textTransform,
            textDecorations: textDecorations,
            leading: leading,
            font: fetchFontTask.value
        )
    }
}

private struct ThrowableDecodable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

extension JSONDecoder {
    func decodeThrowable<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T.Element] where T: Collection, T.Element: Decodable {
        let throwableElements = try decode([ThrowableDecodable<T.Element>].self, from: data)
        return throwableElements.compactMap { try? $0.result.get() }
    }
}
