import Foundation
import CommonCrypto

public final class StreamDecryptError: GenericError {}

public final class StreamDecrypt: StreamCrypto {

        private var accumulatedBytes = [UInt8]()
    private var expectedHmac: [UInt8]?

                    public override func process(bytes: [UInt8]) throws -> [UInt8]? {
        guard self.cryptoConfig != nil else {
            let cryptoConfig = try extractCryptoConfig(fromBytes: bytes)
            self.cryptoConfig = cryptoConfig
            let headerLength = CryptoConfigParser.header(from: cryptoConfig).count
            let iv = Array(bytes[headerLength..<(headerLength + cryptoConfig.ivLength)])
            let hmacLocation = headerLength + cryptoConfig.ivLength
            let expectedHmac = Array(bytes[hmacLocation..<(hmacLocation + hmacAlgorithm.digestLength)])
            self.expectedHmac = expectedHmac
            try updateHmac(withBytes: iv)
            try self.decryptInit(withIV: iv)
                        let encryptedBytesOffset = header.count + iv.count + hmacAlgorithm.digestLength
            accumulatedBytes.append(contentsOf: bytes[encryptedBytesOffset...])
            return nil
        }
        accumulatedBytes.append(contentsOf: bytes)
        guard accumulatedBytes.count >= chunkSize else {
            return nil
        }
        let chunk = Array(accumulatedBytes[0..<chunkSize])
        try updateHmac(withBytes: chunk)
        accumulatedBytes = Array(accumulatedBytes[chunkSize...])
        let outBytes = try updateCrypto(withBytes: chunk)
        return outBytes
    }

        public override func endOfFile() throws {
        if let remainingBytes = try handleRemainingBytes() {
            try write(remainingBytes)
        }
        let outBytes = try endCrypto()
        self.hmac = try endHmac()
        guard let expectedHmac = self.expectedHmac else {
            throw StreamDecryptError("Expected HMAC hash is nil")
        }
        guard self.hmac == expectedHmac else {
            throw StreamDecryptError("HMAC hash does not match")
        }
        try write(outBytes)
    }
}

extension StreamDecrypt {

                        private func extractCryptoConfig(fromBytes bytes: [UInt8]) throws -> CryptoConfig {
        guard let cryptoConfig = CryptoConfigParser.configuration(from: Data( bytes)) else {
            throw StreamDecryptError("Crypto configuration header was not found")
        }
        return cryptoConfig
    }

                    private func decryptInit(withIV iv: [UInt8]) throws {
        guard iv.count == cryptoConfig?.ivLength else {
            throw StreamDecryptError("IV length is not valid: \(iv.count)")
        }
        try initCrypto(withOp: CCOperation(kCCDecrypt), iv: iv)
    }

                private func handleRemainingBytes() throws -> [UInt8]? {
        guard !accumulatedBytes.isEmpty else {
            return nil
        }
        let outBytes = try updateCrypto(withBytes: accumulatedBytes)
        try updateHmac(withBytes: accumulatedBytes)
        return outBytes
    }
}
