import Foundation

public actor CachedDerivationFunction {
    private struct Key: Equatable, Hashable {
        let passwordHash: Int
        let saltHash: Int

        init(passwordHash: Int, saltHash: Int) {
            self.passwordHash = passwordHash
            self.saltHash = saltHash
        }
    }

    private enum Derivation {
        case inProgress(Task<Data, Error>)
        case ready(Data)
    }

    private let baseKeyDerivater: DerivationFunction
    private var cache = [Key: Derivation]()

    public init(baseKeyDerivater: DerivationFunction) {
        self.baseKeyDerivater = baseKeyDerivater
    }

                            public func derivateKey<V: ContiguousBytes & Hashable, S: ContiguousBytes & Hashable>(from password: V, salt: S) async throws -> Data {
        let key = Key(passwordHash: password.hashValue, saltHash: salt.hashValue)
        if let derivation = cache[key] {
            switch derivation {
                case let .inProgress(task):
                    return try await task.value
                case let .ready(data):
                    return data
            }
        } else {
            let task = Task {
                return try baseKeyDerivater.derivateKey(from: password, salt: salt)
            }
            cache[key] = .inProgress(task)
            let value = try await task.value
            cache[key] = .ready(value)
            return value
        }
    }
}

public extension DerivationFunction {
    func cached() -> CachedDerivationFunction {
        return .init(baseKeyDerivater: self)
    }
}
