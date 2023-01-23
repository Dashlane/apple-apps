import Foundation
import Argon2

public struct Argon2d: DerivationFunction {
    public init(timeCost: UInt32 = 3,
                memoryCost: UInt32 = 1 << 15,
                parallelism: UInt32 = 2,
                derivedKeyLength: Int = 32) {
        self.timeCost = timeCost
        self.memoryCost = memoryCost
        self.parallelism = parallelism
        self.derivedKeyLength = derivedKeyLength
    }
    
    public let timeCost: UInt32        
    public let memoryCost: UInt32      
    public let parallelism: UInt32     
    public let derivedKeyLength: Int
    
    public func derivateKey<V: ContiguousBytes, S: ContiguousBytes>(from password: V, salt: S) throws -> Data {
        return try password.withUnsafeBytes { passwordBytes throws -> Data in
            try salt.withUnsafeBytes { saltBytes throws -> Data in
                var derivedKey = [Int8](repeating: 0, count: derivedKeyLength)
                let ret = argon2d_hash_raw(timeCost,
                                           memoryCost,
                                           parallelism,
                                           passwordBytes.baseAddress,
                                           passwordBytes.count,
                                           saltBytes.baseAddress,
                                           saltBytes.count,
                                           &derivedKey,
                                           derivedKeyLength)
                
                switch ret {
                    case ARGON2_OK.rawValue:
                        return .init(bytes: derivedKey, count: derivedKeyLength)
                    default:
                        let error = Argon2dError(rawValue: -ret) ?? Argon2dError.unknown
                        throw KeyDerivaterError.derivationFailed(internalError: error)
                }
            }
        }
    }
}

extension Argon2d {
    public enum Argon2dError: Int32, Error {
        case unknown = 0
        case outputPtrNull = 1
        case outputTooShort
        case outputTooLong
        case passwordTooShort
        case passwordTooLong
        case saltTooShort
        case saltTooLong
        case adTooShort
        case adTooLong
        case secretTooShort
        case secretTooLong
        case timeTooSmall
        case timeTooLarge
        case memoryTooLittle
        case memoryTooMuch
        case lanesTooFew
        case lanesTooMany
        case passwordPtrMismatch
        case saltPtrMismatch
        case secretPtrMismatch
        case adPtrMismatch
        case memoryAllocationError
        case freeMemoryCbkNull
        case allocateMemoryCbkNull
        case incorrectParameter
        case incorrectType
        case outPtrMismatch
        case threadsTooFew
        case threadsTooMany
        case missingArgs
        case encodingFail
        case decodingFail
        case threadFail
        case decodingLengthFail
        case verifyMismatch
    }
}
