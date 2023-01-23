import Foundation

extension SecKey {

    private class func key(fromData data: Data, keyClass: CFString) -> SecKey? {
        var error: Unmanaged<CFError>?
        let dAttributes = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                           kSecAttrKeyClass: keyClass] as NSDictionary
        let key = SecKeyCreateWithData((data as NSData), dAttributes, &error)
        if let error = error {
            error.release()
            return nil
        }
        return key
    }

    class func privateKey(fromData data: Data) -> SecKey? {
        return self.key(fromData: data, keyClass: kSecAttrKeyClassPrivate)
    }

    class func publicKey(fromData data: Data) -> SecKey? {
        return self.key(fromData: data, keyClass: kSecAttrKeyClassPublic)
    }

    public var publicPemFormat: String? {
        guard let data = Data(key: self) else { return nil }
        return data.base64EncodedString().pemFormat(withHeader: RSAKeyConstants.publicKeyHeader,
                                                    footer: RSAKeyConstants.publicKeyFooter)
    }

    public var privatePemFormat: String? {
        guard let data = Data(key: self) else { return nil }
        return data.base64EncodedString().pemFormat(withHeader: RSAKeyConstants.privateKeyHeader,
                                                    footer: RSAKeyConstants.privateKeyFooter)
    }

    public class func privateKey(fromPemString string: String) -> SecKey? {
        let base64 = string.replacingOccurrences(of: RSAKeyConstants.privateKeyHeader, with: "")
            .replacingOccurrences(of: RSAKeyConstants.privateKeyFooter, with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        return SecKey.privateKey(fromData: data)
    }

    public class func publicKey(fromPemString string: String) -> SecKey? {
        let base64 = string.replacingOccurrences(of: RSAKeyConstants.publicKeyHeader, with: "")
            .replacingOccurrences(of: RSAKeyConstants.publicKeyFooter, with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        return SecKey.publicKey(fromData: data)
    }
}
