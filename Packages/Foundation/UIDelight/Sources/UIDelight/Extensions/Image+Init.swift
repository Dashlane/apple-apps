import Foundation
import SwiftUI

#if os(iOS)
public typealias AppImage = UIImage
#elseif os(macOS)
import Cocoa
public typealias AppImage = NSImage
#endif

extension Image {
    public init(appImage: AppImage) {
        #if os(macOS)
        self.init(nsImage: appImage)
        #else
        self.init(uiImage: appImage)
        #endif
    }
}
