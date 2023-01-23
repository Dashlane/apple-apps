#if os(macOS)
import Cocoa
public typealias Image = NSImage

extension NSImage {
    var memoryCost: Int {
        return Int(self.size.height * self.size.width * 4) 
    }
}
#else
import UIKit
public typealias Image = UIImage

extension UIImage {
    var memoryCost: Int {
        guard let cgImage = self.cgImage else {
            return 0
        }
        return Int(cgImage.bytesPerRow * cgImage.height)
    }
}

#endif

import Foundation

public struct Icon {
    public let image: Image?
    public let colors: IconColorSet?

    public init(image: Image?, colors: IconColorSet? = nil) {
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
