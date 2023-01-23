import Foundation

public struct CryptoConfigHasher {

    public static func hash(forConfig config: CryptoConfig, password: String, salt: Data) -> Int? {
        switch config {
        case .kwc3, .kwc5, .noDerivation:
            return nil
        case .argon2dBased(let derivationAlgorithm, _):
            var hasher = Hasher()
            hasher.combine("argon2d")
            hasher.combine(derivationAlgorithm.iterations)
            hasher.combine(derivationAlgorithm.memoryCost)
            hasher.combine(derivationAlgorithm.parallelism)
            hasher.combine(password)
            hasher.combine(salt)
            return hasher.finalize()
        case .pbkdf2Based(let derivationAlgorithm, _):
            guard derivationAlgorithm.iterations >= 100_000 else {
                return nil
            }
            var hasher = Hasher()
            hasher.combine("pbkdf2")
            hasher.combine(derivationAlgorithm.pseudoRandomAlgorithm.CCValue)
            hasher.combine(password)
            hasher.combine(salt)
            return hasher.finalize()
        }
    }
}
