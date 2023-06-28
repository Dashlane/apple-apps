import Foundation

public struct PasswordGeneratorPreferences: Codable, DataConvertible, Equatable {
    public var length: Int
    public var shouldContainLetters: Bool {
        didSet {
                        if !shouldContainLetters {
                shouldContainDigits = true
            }
        }
    }
    public var shouldContainDigits: Bool {
        didSet {
                        if !shouldContainDigits {
                shouldContainLetters = true
            }
        }
    }
    public var shouldContainSymbols: Bool
    public var allowSimilarCharacters: Bool

    public var binaryData: Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            fatalError("Data could not be decoded")
        }
    }

    enum CodingKeys: CodingKey {
        case length
        case shouldContainLetters
        case shouldContainDigits
        case shouldContainSymbols
        case allowSimilarCharacters
    }

    public init?(binaryData: Data) {
        guard let decodedData = try? JSONDecoder().decode(PasswordGeneratorPreferences.self, from: binaryData) else {
            return nil
        }
        self.length = decodedData.length
        self.shouldContainLetters = decodedData.shouldContainLetters
        self.shouldContainDigits = decodedData.shouldContainDigits
        self.shouldContainSymbols = decodedData.shouldContainSymbols
        self.allowSimilarCharacters = decodedData.allowSimilarCharacters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        length = try container.decode(Int.self, forKey: .length)
        shouldContainLetters = try container.decode(Bool.self, forKey: .shouldContainLetters)
        shouldContainDigits = try container.decode(Bool.self, forKey: .shouldContainDigits)
        shouldContainSymbols = try container.decode(Bool.self, forKey: .shouldContainSymbols)
        allowSimilarCharacters = try container.decode(Bool.self, forKey: .allowSimilarCharacters)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(length, forKey: .length)
        try container.encode(shouldContainLetters, forKey: .shouldContainLetters)
        try container.encode(shouldContainDigits, forKey: .shouldContainDigits)
        try container.encode(shouldContainSymbols, forKey: .shouldContainSymbols)
        try container.encode(allowSimilarCharacters, forKey: .allowSimilarCharacters)
    }

    public init(length: Int = 16,
                shouldContainLetters: Bool = true,
                shouldContainDigits: Bool = true,
                shouldContainSymbols: Bool = true,
                allowSimilarCharacters: Bool = false) {
        self.length = length
        self.shouldContainLetters = shouldContainLetters
        self.shouldContainDigits = shouldContainDigits
        self.shouldContainSymbols = shouldContainSymbols
        self.allowSimilarCharacters = allowSimilarCharacters
    }
}
