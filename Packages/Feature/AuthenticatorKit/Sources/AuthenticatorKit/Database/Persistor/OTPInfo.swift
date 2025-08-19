import CoreTypes
import Foundation
import TOTPGenerator

public struct OTPInfo: Equatable, Hashable, Identifiable, Codable, Sendable {
  public let id: Identifier
  public var configuration: OTPConfiguration
  public var recoveryCodes: [String]
  public var isFavorite: Bool

  public init(
    id: Identifier = .init(),
    configuration: OTPConfiguration,
    isFavorite: Bool = false,
    recoveryCodes: [String] = []
  ) {
    self.id = id
    self.configuration = configuration
    self.recoveryCodes = recoveryCodes
    self.isFavorite = isFavorite
  }

  public var isDashlaneOTP: Bool {
    return configuration.issuer?.caseInsensitiveCompare("dashlane") == .orderedSame
      || configuration.issuer?.caseInsensitiveCompare("dashlane.com") == .orderedSame
  }
}

extension OTPInfo {
  public static var mock: OTPInfo {
    return OTPInfo(
      configuration: try! OTPConfiguration(
        otpURL: URL(
          string:
            "otpauth://totp/Test%20Issuer:test%40test.com?secret=yzg6fpgoazbjlhyb3fcilky3dj2oz3ad27dlbtrbf2vqfajazo7albwj&algorithm=SHA256&digits=6&period=30&lock=false"
        )!), isFavorite: false)
  }

  public static var mockWithRecoveryCodes: OTPInfo {
    var token = OTPInfo(
      configuration: try! OTPConfiguration(
        otpURL: URL(
          string:
            "otpauth://totp/Test%20Issuer:test%40test.com?secret=yzg6fpgoazbjlhyb3fcilky3dj2oz3ad27dlbtrbf2vqfajazo7albwj&algorithm=SHA256&digits=6&period=30&lock=false"
        )!), isFavorite: false)
    token.recoveryCodes = [
      "FF46LLAAJ6N4KBHW",
      "2WZZ6VQQFHTDFXCF",
      "NDAJRFU5M4DCKWQE",
      "TTN322MAYAMZHPOA",
      "F2XG64UVVR7S6EIF",
      "TTJXDGVW27QA66P2",
      "LPCL7J4FB4CG5TBO",
      "SYG2WNL6YDGJWCBG",
      "MV5E3RDF7EJ74KOJ",
      "7HZKLDG43U5URY4J",
    ]
    return token
  }
}

extension OTPConfiguration {
  public var issuerOrTitle: String {
    if !title.isEmpty {
      return title
    }
    if let issuer = self.issuer, URL(string: issuer) != nil {
      return issuer
    }
    return issuer ?? ""
  }

  public var iconURL: String {
    if let issuer = self.issuer, URL(string: issuer) != nil {
      return issuer
    }

    return title
  }
}
