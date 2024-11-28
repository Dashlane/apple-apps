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
  public let color: UIColor?

  public init(image: UIImage?, color: UIColor? = nil) {
    self.image = image
    self.color = color
  }
}
extension Icon: Equatable {
  public static func == (lhs: Icon, rhs: Icon) -> Bool {
    return lhs.color == rhs.color && lhs.image === rhs.image
  }
}

extension Icon {
  var memoryCost: Int {
    image?.memoryCost ?? 0
  }
}
