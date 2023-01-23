import Foundation
import Argon2

public struct Argon2 {

    let timeCost: UInt32        
    let memoryCost: UInt32      
    let parallelism: UInt32     

        public func argon2dHash(of text: String, derivedKeyLength: Int = 32) -> Data? {
        return argon2dHash(of: text, addingSalt: generate16BytesSalt(), derivedKeyLength: derivedKeyLength)
    }

    public func argon2dHash(of text: String, addingSalt salt: [UInt8], derivedKeyLength: Int) -> Data? {
        guard let textToHash = text.cString(using: .utf8) else {
            return nil
        }
        var hash = [UInt8].init(repeating: 0, count: derivedKeyLength)
        let ret = argon2d_hash_raw(timeCost,
                                   memoryCost,
                                   parallelism,
                                   textToHash,
                                   textToHash.count - 1,
                                   salt,
                                   salt.count,
                                   &hash,
                                   derivedKeyLength)
        guard ret == ARGON2_OK.rawValue else {
            return nil
        }
        return Data(hash)
    }

                                public init(timeCost: UInt32 = 3, memoryCost: UInt32 = 1 << 15, parallelism: UInt32 = 2) {
        self.timeCost = timeCost
        self.memoryCost = memoryCost
        self.parallelism = parallelism
    }

        private func randomByteArray(ofSize size: Int) -> [UInt8] {
        var bytesArray = [UInt8](repeating: 0, count: size)
        _ = SecRandomCopyBytes(kSecRandomDefault, size, &bytesArray)
        return bytesArray
    }

    private func randomData(ofSize size: Int) -> Data {
        return Data( randomByteArray(ofSize: size))
    }

    private func generate32BytesSalt() -> [UInt8] {
        return self.randomByteArray(ofSize: 32)
    }

    private func generate16BytesSalt() -> [UInt8] {
        return self.randomByteArray(ofSize: 16)
    }

}
