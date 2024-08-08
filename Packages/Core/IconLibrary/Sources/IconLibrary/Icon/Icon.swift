import Foundation
import UIKit

extension UIImage {
  var memoryCost: Int {
    guard let cgImage = self.cgImage else {
      return 0
    }
    return Int(cgImage.bytesPerRow * cgImage.height)
  }
}

public struct Icon: Sendable {
  public let image: UIImage?
  public let colors: IconColorSet?

  public init(image: UIImage?, colors: IconColorSet? = nil) {
    self.image = image
    self.colors = colors
  }
}
extension Icon: Equatable {
  public static func == (lhs: Icon, rhs: Icon) -> Bool {
    return lhs.colors == rhs.colors && lhs.image === rhs.image
  }
}

extension Icon {
  var memoryCost: Int {
    image?.memoryCost ?? 0
  }
}
