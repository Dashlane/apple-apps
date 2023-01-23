import Foundation
import CryptoKit

public struct RequestSigner {
    private enum AuthorizationKey: String {
        case login = "Login"
        case appAccessKey = "AppAccessKey"
        case deviceAccessKey = "DeviceAccessKey"
        case timestamp = "Timestamp"
        case signedHeaders = "SignedHeaders"
        case signature = "Signature"

        func component(forValue value: String) -> String {
            return rawValue + "=" + value
        }
    }

    static var signatureAlgorithmKey = "DL1-HMAC-SHA256"

    let appCredentials: AppCredentials
    let userCredentials: UserCredentials?
    let signingKey: SymmetricKey

    init(appCredentials: AppCredentials,
         userCredentials: UserCredentials?) {
        self.appCredentials = appCredentials
        self.userCredentials = userCredentials

        let signingKey: String
        if let userCredentials = userCredentials {
            signingKey = [appCredentials.secretKey, userCredentials.deviceSecretKey].joined(separator: "\n")
        } else {
            signingKey = appCredentials.secretKey
        }

        self.signingKey = SymmetricKey(data: signingKey.data(using: .utf8)!)
    }

    func sign(_ request: URLRequest, timeshift: TimeInterval) throws -> String {
        let canonicalRequest = try request.canonicalizedRequest()
        let timestamp: String
        if let bootTime = TimeInterval.currentKernelBootTime() {
            timestamp = String(Int(bootTime + timeshift))
        } else {
            timestamp = String(Int(Date().timeIntervalSince1970 + timeshift))
        }

        return makeSignature(canonicalRequest: canonicalRequest, timestamp: timestamp)
    }

    func makeSignature(canonicalRequest: URLRequest.CanonicalRequest, timestamp: String) -> String {
        let canonicalizedRequestData = canonicalRequest.request.data(using: .utf8)!
        let hashedCanonilizedRequest = SHA256.hash(data: canonicalizedRequestData).hexEncodedString()

        let stringToSign = [
            Self.signatureAlgorithmKey,
            timestamp,
            hashedCanonilizedRequest
        ].joined(separator: "\n")
         .data(using: .utf8)!

        let signature = HMAC<SHA256>.authenticationCode(for: stringToSign, using: signingKey).hexEncodedString()

        let authorizationArray: [String]
        if let userCredentials = userCredentials {
                        authorizationArray = [
                AuthorizationKey.login.component(forValue: userCredentials.login),
                AuthorizationKey.appAccessKey.component(forValue: appCredentials.accessKey),
                AuthorizationKey.deviceAccessKey.component(forValue: userCredentials.deviceAccessKey),
                AuthorizationKey.timestamp.component(forValue: timestamp),
                AuthorizationKey.signedHeaders.component(forValue: canonicalRequest.headers),
                AuthorizationKey.signature.component(forValue: signature)
            ]
        } else {
            authorizationArray = [
                AuthorizationKey.appAccessKey.component(forValue: appCredentials.accessKey),
                AuthorizationKey.timestamp.component(forValue: timestamp),
                AuthorizationKey.signedHeaders.component(forValue: canonicalRequest.headers),
                AuthorizationKey.signature.component(forValue: signature)
            ]
        }
        return Self.signatureAlgorithmKey + " " +  authorizationArray.joined(separator: ",")
    }
}

extension URLRequest {
    mutating func sign(with signer: RequestSigner, timeshift: TimeInterval) throws {
        let authorizationHeader = try signer.sign(self, timeshift: timeshift)
        self.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
    }
}

 extension Sequence where Element == UInt8 {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

public enum SignatureError: Error {
        case invalidURL
}
