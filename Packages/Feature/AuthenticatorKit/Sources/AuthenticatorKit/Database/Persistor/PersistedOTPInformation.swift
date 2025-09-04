import CoreTypes
import Foundation

public struct PersistedOTPInformation: Codable {
  let id: Identifier
  let otpURL: URL
  let title: String?
  let login: String?
  let issuer: String?
  let recoveryCodes: [String]
  let isFavorite: Bool?
}
