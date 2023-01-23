import Foundation
import CommonCrypto

public final class StreamEncryptError: GenericError {}

public final class StreamEncrypt: StreamCrypto {

    var streamEditor: StreamEditor?

    public override init(source: URL,
                         destination: URL,
                         key: Data,
                         chunkSize: Int,
                         aesMode: AESMode = .cbchmac,
                         hmacAlgorithm: HMACAlgorithm = .sha256,
                         completionHandler handler: StreamTransferCompletionHandler?) throws {

        let temporaryFileLocation = destination.appendingPathExtension("tmp")

        let editorCompletionHandler: (Result<StreamTransfer, Error>) -> Void = { result in
            do {
                try FileManager.default.removeItem(at: temporaryFileLocation)
                handler?(result)
            } catch {
                handler?(.failure(error))
            }
        }

        let encryptionCompletionHandler: (Result<StreamTransfer, Error>) -> Void = { result in
            switch result {
            case .success(let streamObject):
                guard let streamEncryptObject = streamObject as? StreamEncrypt else {
                    handler?(result)
                    return
                }
                do {
                    let streamEditor = try StreamEditor(source: temporaryFileLocation,
                                                        destination: destination,
                                                        completionHandler: editorCompletionHandler)
                    let location = streamEncryptObject.header.count + streamEncryptObject.iv.count
                    let dataReplacement = try DataReplacement(Data( streamEncryptObject.hmac), startLocation: location)
                    streamEditor.add(replacement: dataReplacement)
                    try streamEditor.start()
                    streamEncryptObject.streamEditor = streamEditor
                } catch {
                    handler?(.failure(error))
                }
            case .failure:
                handler?(result)
            }
        }

        try super.init(source: source,
                       destination: temporaryFileLocation,
                       key: key,
                       chunkSize: chunkSize,
                       aesMode: aesMode,
                       hmacAlgorithm: hmacAlgorithm,
                       completionHandler: encryptionCompletionHandler)
    }

            public override func start() throws {
        let cryptoConfig = CryptoConfigParser.configuration(from: header)!
        let iv = Random.randomByteArray(ofSize: cryptoConfig.ivLength)
        self.iv = iv
        self.cryptoConfig = cryptoConfig
        try self.encryptInit(withIV: iv)
        try super.start()
    }

                    public override func startOfFile() throws {
        try write([UInt8](header) + iv + [UInt8](repeating: 0, count: hmacAlgorithm.digestLength ))
    }

                        public override func process(bytes: [UInt8]) throws -> [UInt8]? {
        let outBytes = try updateCrypto(withBytes: bytes)
        try updateHmac(withBytes: outBytes)
        return outBytes
    }

        public override func endOfFile() throws {
        let outBytes = try endCrypto()
        try updateHmac(withBytes: outBytes)
        self.hmac = try endHmac()
        try write(outBytes)
    }
}

extension StreamEncrypt {

                    private func encryptInit(withIV iv: [UInt8]) throws {
        guard iv.count == cryptoConfig?.ivLength else {
            throw StreamEncryptError("IV length is not valid: \(iv.count)")
        }
        try initCrypto(withOp: CCOperation(kCCEncrypt), iv: iv)
        try updateHmac(withBytes: self.iv)
    }
}
