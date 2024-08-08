import Foundation

struct ColorAsset: Encodable {
  let name: String
  let nameComponents: [String]
  let lightModeValue: RGBAValue
  let darkModeValue: RGBAValue

  func encode(to encoder: Encoder) throws {
    try ColorFile(lightModeColor: lightModeValue, darkModeColor: darkModeValue).encode(to: encoder)
  }
}
