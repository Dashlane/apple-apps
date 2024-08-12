import Foundation

public struct OTPConfiguration: Equatable, Hashable, Codable, Sendable {
  enum Key: String {
    case secret
    case issuer
    case algorithm
    case digits
  }
  static let dashlaneIssuer: [String] = ["dashlane", "dashlane.com"]
  public let otpURL: URL
  public var title: String
  public var login: String
  public var issuer: String?
  public let type: OTPType
  public let secret: Data
  public let digits: Int
  public let algorithm: HashAlgorithm

  public init(
    otpString: String,
    supportDashlane2FA: Bool = false
  ) throws {
    let cleaned =
      otpString.removingPercentEncoding?.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed) ?? otpString
    guard let url = URL(string: cleaned) else {
      throw OTPUrlParserError.incorrectURLFormat
    }
    try self.init(otpURL: url, supportDashlane2FA: supportDashlane2FA)
  }

  public init(
    otpURL: URL,
    supportDashlane2FA: Bool = false,
    defaultTitle: String? = nil,
    defaultLogin: String? = nil,
    defaultIssuer: String? = nil
  ) throws {
    self.otpURL = otpURL
    guard let components = URLComponents(url: otpURL, resolvingAgainstBaseURL: false),
      let type = OTPType(urlComponents: components),
      let secret = components.queryItems?[Key.secret.rawValue],
      !secret.isEmpty
    else {
      throw OTPUrlParserError.incorrectFormat
    }

    if let label = components.path.components(separatedBy: "/").last {
      self.title = defaultTitle ?? label.components(separatedBy: ":").first ?? ""
      self.login = defaultLogin ?? label.components(separatedBy: ":").last ?? ""
    } else {
      self.title = defaultTitle ?? ""
      self.login = defaultLogin ?? ""
    }

    self.type = type
    self.secret = try secret.secretData()

    if let issuer = defaultIssuer {
      self.issuer = issuer
    } else if let issuerInQueryItems = components.queryItems?[Key.issuer.rawValue] {
      self.issuer = issuerInQueryItems
    } else if let issuerFromLabel = components.path.components(separatedBy: "/").last?.components(
      separatedBy: ":"
    ).first {
      self.issuer = issuerFromLabel
    } else {
      self.issuer = nil
    }

    if let algo = components.queryItems?[Key.algorithm.rawValue],
      let hashAlgorithm = HashAlgorithm(rawValue: algo.lowercased())
    {
      self.algorithm = hashAlgorithm
    } else {
      self.algorithm = .sha1
    }
    if let digitValue = components.queryItems?[Key.digits.rawValue], let digit = Int(digitValue) {
      self.digits = digit
    } else {
      self.digits = 6
    }
    try checkDashlane2FA(supportDashlane2FA: supportDashlane2FA)
  }

  private func checkDashlane2FA(supportDashlane2FA: Bool) throws {
    guard !supportDashlane2FA else { return }

    if let issuer = issuer {
      guard !Self.dashlaneIssuer.contains(issuer.lowercased()) else {
        throw OTPUrlParserError.dashlaneSecretDetected
      }
    }
    guard !Self.dashlaneIssuer.contains(title.lowercased()) else {
      throw OTPUrlParserError.dashlaneSecretDetected
    }
  }

  public var issuerURL: URL? {
    if let url = URL(string: title) {
      return url
    } else if let issuer = issuer, let url = URL(string: issuer) {
      return url
    }
    return nil
  }
}

extension String {
  fileprivate func secretData() throws -> Data {
    guard let data = base32DecodedData as Data? else {
      throw OTPUrlParserError.incorrectSecret
    }
    return data
  }
}

extension OTPConfiguration {
  public static var mock: OTPConfiguration {
    return try! OTPConfiguration(
      otpURL: URL(
        string:
          "otpauth://totp/Test%20Issuer:test%40test.com?secret=yzg6fpgoazbjlhyb3fcilky3dj2oz3ad27dlbtrbf2vqfajazo7albwj&algorithm=SHA256&digits=6&period=30&lock=false"
      )!)
  }
}

public enum OTPUrlParserError: Error {
  case incorrectFormat
  case incorrectSecret
  case dashlaneSecretDetected
  case incorrectURLFormat
}
