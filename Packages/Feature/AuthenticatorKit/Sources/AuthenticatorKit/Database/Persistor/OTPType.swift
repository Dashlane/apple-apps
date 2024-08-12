import Foundation

enum OTPType {

  case totp(period: TimeInterval = 30)
  case hotp(UInt64)

  init?(urlComponents: URLComponents) {
    guard let type = urlComponents.host else {
      return nil
    }
    switch type {
    case "totp":
      if let value = urlComponents.queryItems?["period"], let period = TimeInterval(value) {
        self = .totp(period: period)
      } else {
        self = .totp()
      }
    case "hotp":
      guard let value = urlComponents.queryItems?["counter"], let counter = UInt64(value) else {
        return nil
      }
      self = .hotp(counter)
    default:
      return nil
    }
  }

  func counterValue(for time: Date, currentCounter: UInt64?) -> UInt64 {
    switch self {
    case .hotp(let counter):
      return currentCounter ?? counter
    case .totp(let period):
      let timeSinceEpoch = time.timeIntervalSince1970
      return UInt64(timeSinceEpoch / period)
    }
  }
}

extension OTPType: Codable {
  enum CodingKeys: CodingKey {
    case type
    case value
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    switch type {
    case "totp":
      let period = try container.decode(TimeInterval.self, forKey: .value)
      self = .totp(period: period)
    default:
      let counter = try container.decode(UInt64.self, forKey: .value)
      self = .hotp(counter)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .totp(period):
      try container.encode("totp", forKey: .type)
      try container.encode(period, forKey: .value)
    case let .hotp(couter):
      try container.encode("hotp", forKey: .type)
      try container.encode(couter, forKey: .value)
    }
  }

}

extension Sequence where Iterator.Element == URLQueryItem {
  subscript(name: String) -> String? {
    return self.first { $0.name == name }?.value
  }
}
