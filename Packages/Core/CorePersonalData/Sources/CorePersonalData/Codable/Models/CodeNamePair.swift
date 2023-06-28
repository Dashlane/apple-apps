import Foundation

public protocol CodeNamePair {
    static var codeFormat: CodeFormat { get }
    var code: String { get }
    var name: String { get }
    init(code: String, name: String)
}

public struct RegionCodeComponentsInfo {
    public let countryCode: String
    public let subcode: String
    public init(countryCode: String, subcode: String) {
        self.countryCode = countryCode
        self.subcode = subcode
    }

    public init?(combinedCode: String) {
        let components = combinedCode.split(separator: "-")
        guard let countryCode = components.first,
            let stateCode = components.last,
            countryCode != stateCode else {
                return nil
        }

        self.countryCode = String(countryCode)
        self.subcode = String(stateCode)
    }
}

public extension CodeNamePair {
    var components: RegionCodeComponentsInfo? {
        let components = code.components(separatedBy: CharacterSet(charactersIn: "-"))
        guard components.count > 1,
            let countryCode = components.first,
            let subcode = components.last else {
                return nil
        }
        return RegionCodeComponentsInfo(countryCode: countryCode, subcode: subcode)
    }
}

public extension RegionCodeComponentsInfo {
    var localizedCountry: String? {
        return Locale.current.localizedString(forRegionCode: countryCode)
    }
}

extension CodeNamePair {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let code = try container.decode(String.self)
        self.init(code: code, name: "")
    }
}
