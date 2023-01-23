import Foundation
import Security


public enum RSA { }

extension RSA {
    public enum SignatureVariant {
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512

        var algorithm: SecKeyAlgorithm {
            switch self {
            case .sha1:
                return .rsaSignatureMessagePKCS1v15SHA1
            case .sha224:
                return .rsaSignatureMessagePKCS1v15SHA224
            case .sha256:
                return .rsaSignatureMessagePKCS1v15SHA256
            case .sha384:
                return .rsaSignatureMessagePKCS1v15SHA384
            case .sha512:
                return .rsaSignatureMessagePKCS1v15SHA512
            }
        }
    }
    
                public struct MessageSigner: CyrilKit.MessageSigner {
        public let privateKey: PrivateKey
        public let variant: SignatureVariant
        
        public init(privateKey: PrivateKey, variant: SignatureVariant = .sha512) {
            self.privateKey = privateKey
            self.variant = variant
        }
        
        public func sign(_ data: Message) throws -> Signature {
            var error: Unmanaged<CFError>?
            defer {
                error?.release()
            }

            let signedData = SecKeyCreateSignature(privateKey.secKey,
                                                   variant.algorithm,
                                                   data as CFData,
                                                   &error)
            guard error == nil, let data = signedData as? Data else {
                throw RSAError.signFailed
            }
            
            return .init(data)
        }
    }
    
                public struct SignatureVerifier: CyrilKit.SignatureVerifier {
        public let publicKey: PublicKey
        public let variant: SignatureVariant
        
        public init(publicKey: PublicKey, variant: SignatureVariant = .sha512) {
            self.publicKey = publicKey
            self.variant = variant
        }
        
        public func verify(_ data: Message, with signature: Signature) -> Bool {
            var error: Unmanaged<CFError>?
            defer {
                error?.release()
            }
            let result = SecKeyVerifySignature(publicKey.secKey,
                                               variant.algorithm,
                                               data as CFData,
                                               signature.data as CFData,
                                               &error)
            return error == nil ? result : false
        }
    }
}



extension SecPadding {
    var blockOffset: Int {
        switch self {
        case .OAEP:
            return 66
        case .sigRaw:
            return 0
        default:
            return 11
        }
    }
}

extension RSA {
    public enum EncryptionVariant {
                public enum OAEPHashVariant {
            case sha1
            case sha224
            case sha256
            case sha384
            case sha512
        }
        
        case raw
                case oaep(OAEPHashVariant)
      
        var algorithm: SecKeyAlgorithm {
            switch self {
            case .raw:
                return .rsaEncryptionRaw
            case let .oaep(hash):
                switch hash {
                case .sha1:
                    return .rsaEncryptionOAEPSHA1
                case .sha224:
                    return .rsaEncryptionOAEPSHA224
                case .sha256:
                    return .rsaEncryptionOAEPSHA256
                case .sha384:
                    return .rsaEncryptionOAEPSHA384
                case .sha512:
                    return .rsaEncryptionOAEPSHA512
                }
            }
        }
        
        var blockOffset: Int {
            switch self {
            case .oaep:
                return 66 
            case .raw:
                return 0
            }
        }
    }

        public struct Encrypter: CyrilKit.Encrypter {
        let variant: EncryptionVariant
        let publicKey: PublicKey
        
        public init(publicKey: PublicKey,
                    variant: EncryptionVariant = .oaep(.sha256)) {
            self.variant = variant
            self.publicKey = publicKey
        }
        
        private func encryptBlock(_ data: Data) throws -> Data {
            var error: Unmanaged<CFError>?
            defer {
                error?.release()
            }
            guard SecKeyIsAlgorithmSupported(publicKey.secKey, .encrypt, variant.algorithm) == true,
                  let encryptedData = SecKeyCreateEncryptedData(publicKey.secKey, variant.algorithm, data as CFData, &error) else {
                throw RSAError.encryptFailed
            }
            return encryptedData as Data
        }
        
        public func encrypt(_ dataToEncrypt: Data) throws -> Data {
            let blockLength = SecKeyGetBlockSize(publicKey.secKey) - variant.blockOffset
            guard dataToEncrypt.count > blockLength else {
                return try encryptBlock(dataToEncrypt)
            }
            
            var encryptedData = Data()
            var position = 0
            while position < dataToEncrypt.count {
                let range = position..<min(position+blockLength, dataToEncrypt.count)
                let encryptedBlock = try encryptBlock(dataToEncrypt.subdata(in: range))
                encryptedData.append(encryptedBlock)
                position += blockLength
            }
            
            return encryptedData
        }
    }
    
        public struct Decrypter: CyrilKit.Decrypter {
        let variant: EncryptionVariant
        let privateKey: PrivateKey
        
        public init(privateKey: PrivateKey,
                    variant: EncryptionVariant = .oaep(.sha256)) {
            self.variant = variant
            self.privateKey = privateKey
        }
        
        private func decryptBlock(_ data: Data) throws -> Data {
            var error: Unmanaged<CFError>?
            defer {
                error?.release()
            }
            guard SecKeyIsAlgorithmSupported(privateKey.secKey, .decrypt, variant.algorithm),
                  let decryptedData = SecKeyCreateDecryptedData(privateKey.secKey, variant.algorithm, data as CFData, &error) else {
                throw RSAError.decryptFailed
            }
            return decryptedData as Data
        }
        
        public func decrypt(_ dataToDecrypt: Data) throws -> Data {
            let blockLength = SecKeyGetBlockSize(privateKey.secKey)
            guard dataToDecrypt.count > blockLength else {
                return try decryptBlock(dataToDecrypt)
            }
            
            var decryptedData = Data()
            var position = 0
            while position < dataToDecrypt.count {
                let range = position..<min(position+blockLength, dataToDecrypt.count)
                let decryptedBlock = try decryptBlock(dataToDecrypt.subdata(in: range))
                decryptedData.append(decryptedBlock)
                position = position + blockLength
            }
            return decryptedData
        }
        
    }
}
