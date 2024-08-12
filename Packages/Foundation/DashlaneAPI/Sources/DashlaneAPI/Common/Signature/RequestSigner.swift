import Foundation

#if canImport(CryptoKit)
  @preconcurrency import CryptoKit
#elseif canImport(Crypto)
  import Crypto
#endif

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct RequestSigner: Sendable {
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
  let timeshiftProvider: TimeshiftProvider

  init(
    appCredentials: AppCredentials,
    userCredentials: UserCredentials?,
    timeshiftProvider: TimeshiftProvider
  ) {
    self.appCredentials = appCredentials
    self.userCredentials = userCredentials

    let signingKey: String
    if let userCredentials = userCredentials {
      signingKey = [appCredentials.secretKey, userCredentials.deviceSecretKey].joined(
        separator: "\n")
    } else {
      signingKey = appCredentials.secretKey
    }

    self.signingKey = SymmetricKey(data: signingKey.data(using: .utf8)!)
    self.timeshiftProvider = timeshiftProvider
  }

  func sign(_ request: URLRequest) async throws -> String {
    let timeshift = try await timeshiftProvider.timeshift
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
    let hashedCanonicalizedRequest = SHA256.hash(data: canonicalizedRequestData).hexEncodedString()

    let stringToSign = [
      Self.signatureAlgorithmKey,
      timestamp,
      hashedCanonicalizedRequest,
    ].joined(separator: "\n")
      .data(using: .utf8)!

    let signature = HMAC<SHA256>.authenticationCode(for: stringToSign, using: signingKey)
      .hexEncodedString()

    let authorizationArray: [String]
    if let userCredentials = userCredentials {
      authorizationArray = [
        AuthorizationKey.login.component(forValue: userCredentials.login),
        AuthorizationKey.appAccessKey.component(forValue: appCredentials.accessKey),
        AuthorizationKey.deviceAccessKey.component(forValue: userCredentials.deviceAccessKey),
        AuthorizationKey.timestamp.component(forValue: timestamp),
        AuthorizationKey.signedHeaders.component(forValue: canonicalRequest.headers),
        AuthorizationKey.signature.component(forValue: signature),
      ]
    } else {
      authorizationArray = [
        AuthorizationKey.appAccessKey.component(forValue: appCredentials.accessKey),
        AuthorizationKey.timestamp.component(forValue: timestamp),
        AuthorizationKey.signedHeaders.component(forValue: canonicalRequest.headers),
        AuthorizationKey.signature.component(forValue: signature),
      ]
    }
    return Self.signatureAlgorithmKey + " " + authorizationArray.joined(separator: ",")
  }
}

extension URLRequest {
  mutating func sign(with signer: RequestSigner) async throws {
    let authorizationHeader = try await signer.sign(self)
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
