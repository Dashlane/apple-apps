public struct RegionInformationContainer<T: Decodable>: Decodable {
        public let region: String
        public let items: [T]
            public let level: String?
}

public protocol RegionInformationProtocol {
    static var resourceType: ResourceType { get }
    var code: String { get }
    var localizedString: String { get }
}

public extension Collection where Element: RegionInformationProtocol {
    func item(forCode code: String) -> Element? {
        let upperCasedCode = code.uppercased()
        return self.first { $0.code == upperCasedCode }
    }
}

public struct RegionContainer<T: Decodable>: Decodable {
    let regions: [RegionInformationContainer<T>]
}
