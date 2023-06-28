import Foundation
import CommonCrypto

public struct AES {

        fileprivate static func recursiveCrypt(data: Data,
                                           withKey key: Data,
                                           mode: AESMode = .cbc,
                                           initializationVector iv: [UInt8],
                                           operation: CCOperation,
                                           bufferSize: Int? = nil) -> Data? {

        let bufferSize = bufferSize ?? data.count + kCCBlockSizeAES128 
        var buffer = [UInt8](repeating: 0, count: bufferSize )
        var dataOutMoved = 0
        let status = CCCrypt(operation,
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(mode.CCValue),
                             [UInt8](key),
                             kCCKeySizeAES256,
                             iv,
                             [UInt8](data),
                             data.count,
                             &buffer,
                             buffer.count,
                             &dataOutMoved)
        guard status == kCCSuccess else {
            if status == CCCryptorStatus(kCCBufferTooSmall) {
                return AES.recursiveCrypt(data: data,
                                          withKey: key,
                                          mode: mode,
                                          initializationVector: iv,
                                          operation: operation,
                                          bufferSize: bufferSize * 4/3) 
            }
            return nil
        }
        return Data(buffer).subdata(in: 0..<dataOutMoved)
    }

    public static func encrypt(data: Data,
                               withKey key: Data,
                               mode: AESMode = .cbc,
                               initializationVector iv: [UInt8]) -> Data? {
        return AES.recursiveCrypt(data: data,
                                  withKey: key,
                                  mode: mode,
                                  initializationVector: iv,
                                  operation: CCOperation(kCCEncrypt))
    }

    public static func decrypt(data: Data,
                               withKey key: Data,
                               mode: AESMode = .cbc,
                               initializationVector iv: [UInt8]) -> Data? {
        return AES.recursiveCrypt(data: data,
                                  withKey: key,
                                  mode: mode,
                                  initializationVector: iv,
                                  operation: CCOperation(kCCDecrypt))
    }

}
