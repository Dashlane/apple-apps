#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIKit

  public typealias AppImage = UIImage

  extension Image {
    public init(appImage: AppImage) {
      self.init(uiImage: appImage)
    }
  }
#endif
