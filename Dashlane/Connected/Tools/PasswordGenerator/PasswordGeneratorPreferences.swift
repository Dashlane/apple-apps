import Foundation
import Settings
import DashlanePasswordKit
import DashlanePersonalData

class PasswordGeneratorPreferences: ObservableObject, Codable, DataConvertible {

    @Published
    var length: Double

    @Published
    var shouldContainLetters: Bool

    @Published
    var shouldContainDigits: Bool

    @Published
    var shouldContainSymbols: Bool

    @Published
    var allowSimilarCharacters: Bool

    var binaryData: Data {
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

    required init?(binaryData: Data) {
        guard let decodedData = try? JSONDecoder().decode(PasswordGeneratorPreferences.self, from: binaryData) else {
            return nil
        }
        self.length = decodedData.length
        self.shouldContainLetters = decodedData.shouldContainLetters
        self.shouldContainDigits = decodedData.shouldContainDigits
        self.shouldContainSymbols = decodedData.shouldContainSymbols
        self.allowSimilarCharacters = decodedData.allowSimilarCharacters
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let integerLength = try container.decode(Int.self, forKey: .length)
        length = Double(integerLength)
        shouldContainLetters = try container.decode(Bool.self, forKey: .shouldContainLetters)
        shouldContainDigits = try container.decode(Bool.self, forKey: .shouldContainDigits)
        shouldContainSymbols = try container.decode(Bool.self, forKey: .shouldContainSymbols)
        allowSimilarCharacters = try container.decode(Bool.self, forKey: .allowSimilarCharacters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(length), forKey: .length)
        try container.encode(shouldContainLetters, forKey: .shouldContainLetters)
        try container.encode(shouldContainDigits, forKey: .shouldContainDigits)
        try container.encode(shouldContainSymbols, forKey: .shouldContainSymbols)
        try container.encode(allowSimilarCharacters, forKey: .allowSimilarCharacters)
    }

    init(length: Int = 16,
         shouldContainLetters: Bool = true,
         shouldContainDigits: Bool = true,
         shouldContainSymbols: Bool = true,
         allowSimilarCharacters: Bool = true) {
        self.length = Double(length)
        self.shouldContainLetters = shouldContainLetters
        self.shouldContainDigits = shouldContainDigits
        self.shouldContainSymbols = shouldContainSymbols
        self.allowSimilarCharacters = allowSimilarCharacters
    }
}
