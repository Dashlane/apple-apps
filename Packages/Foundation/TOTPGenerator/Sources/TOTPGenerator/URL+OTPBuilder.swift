import Foundation

extension URL {

  public enum OTPURLError: Error {
    case cannotBuildURLFromItems
  }

  public static func makeOTPURL(
    title: String,
    login: String,
    issuer: String?,
    type: OTPType = .totp(period: 30),
    secret: String,
    digits: Int = 6,
    algorithm: HashAlgorithm = .sha1
  ) throws -> URL {
    var otpURL = URLComponents(string: "")!

    otpURL.scheme = "otpauth"
    otpURL.host = type.rawValue
    otpURL.path =
      "/\(title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title)"
      + ":\(login.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? login)"

    var queryItems: [URLQueryItem] = [
      URLQueryItem(name: "secret", value: secret),
      URLQueryItem(
        name: "issuer",
        value: issuer?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
      URLQueryItem(name: "algorithm", value: algorithm.rawValue.uppercased()),
      URLQueryItem(name: "digits", value: "\(digits)"),
    ]

    switch type {
    case .totp(let period):
      queryItems.append(URLQueryItem(name: "period", value: "\(period)"))
    case .hotp(let counter):
      queryItems.append(URLQueryItem(name: "counter", value: "\(counter)"))
    }
    otpURL.queryItems = queryItems

    guard let url = otpURL.url else {
      throw OTPURLError.cannotBuildURLFromItems
    }

    return url
  }
}
