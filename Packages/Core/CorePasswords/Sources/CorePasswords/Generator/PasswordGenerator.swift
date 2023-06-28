import Foundation

public struct PasswordGenerator {
    let availableCharacters: [Character]
    let characterSets: [Set<Character>]
    let length: Int

                            public init(length: Int = 16, composition: PasswordCompositionOptions = .all, distinguishable: Bool = false) {
        self.length = max(length, 4)
        let composition = composition.isEmpty ? .all : composition
        self.characterSets = composition.allCharacterSets(distinguishable: distinguishable)
        self.availableCharacters = characterSets.flatMap { Array($0) }
    }

            public func generate() -> String {
        var password = String()
        password.reserveCapacity(length)

        var iteration: Int = 0

        repeat {
            iteration += 1
            password.fill(using: availableCharacters, length: length)
        } while iteration < 1000 && !characterSets.isValid(password)

        return password
    }
}

private extension String {
    mutating func fill(using characters: [Character], length: Int) {
        removeAll(keepingCapacity: true)

        for _ in 0..<length {
            guard let character = characters.randomElement() else {
                assertionFailure()
                return
            }
            self.append(character)
        }
    }
}

private extension Array<Set<Character>> {
    func isValid(_ password: String) -> Bool {
        for characterSet in self {
            guard password.contains(where: characterSet.contains) else {
                return false
            }
        }

        return true
    }
}

public extension PasswordGenerator {
    static let deeplink: String = "password-generator"
}
