import Foundation

extension String {
  public func lowercasingFirstLetter() -> String {
    return prefix(1).lowercased() + dropFirst()
  }

  public mutating func lowercaseFirstLetter() {
    self = self.lowercasingFirstLetter()
  }
}

extension String {
  public func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  public mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
}
