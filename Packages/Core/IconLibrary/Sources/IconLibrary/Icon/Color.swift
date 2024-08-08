import DashlaneAPI
import Foundation
import UIKit

public struct IconColorSet: Codable, Equatable, Sendable {
  public let backgroundColor: UIColor
  public let mainColor: UIColor
  public let fallbackColor: UIColor

  enum CodingKeys: CodingKey {
    case backgroundColorCode
    case mainColorCode
    case fallbackColorCode
  }

  public init(backgroundColor: UIColor, mainColor: UIColor, fallbackColor: UIColor) {
    self.backgroundColor = backgroundColor
    self.mainColor = mainColor
    self.fallbackColor = fallbackColor
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let backgroundCode = try container.decode(String.self, forKey: .backgroundColorCode)
    let mainCode = try container.decode(String.self, forKey: .mainColorCode)
    let fallbackCode = try container.decode(String.self, forKey: .fallbackColorCode)

    let mainColor = UIColor(ciColor: CIColor(string: mainCode))
    let backgroundColor = UIColor(ciColor: CIColor(string: backgroundCode))
    let fallbackColor = UIColor(ciColor: CIColor(string: fallbackCode))

    self.init(backgroundColor: backgroundColor, mainColor: mainColor, fallbackColor: fallbackColor)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(backgroundColor.rawRepresentation, forKey: .backgroundColorCode)
    try container.encode(fallbackColor.rawRepresentation, forKey: .fallbackColorCode)
    try container.encode(mainColor.rawRepresentation, forKey: .mainColorCode)
  }
}

extension IconColorSet {
  init?(iconDescription: AppAPIClient.Iconcrawler.GetIcons.Response.IconsElement?) {
    guard let iconDescription = iconDescription else { return nil }

    guard let backgroundColor = UIColor(withHexCode: iconDescription.backgroundColor),
      let mainColor = UIColor(withHexCode: iconDescription.mainColor),
      let fallbackColor = UIColor(withHexCode: iconDescription.fallbackColor)
    else {
      return nil
    }

    self.backgroundColor = backgroundColor
    self.fallbackColor = fallbackColor
    self.mainColor = mainColor
  }
}

extension UIColor {
  convenience init?(withHexCode hex: String?) {
    guard let hex = hex else { return nil }
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
      cString = String(cString.dropFirst())
    }

    guard cString.count == 6 else {
      return nil
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}

extension UIColor {
  var colorsSet: IconColorSet {
    return IconColorSet(backgroundColor: self, mainColor: self, fallbackColor: self)
  }
}

extension UIColor {
  var rawRepresentation: String? {
    return CIColor(color: self).stringRepresentation
  }
}
