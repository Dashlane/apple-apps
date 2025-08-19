#if canImport(UIKit)
  import UIKit

  extension UIView {
    public func imageFromLayer() -> UIImage {
      let renderer = UIGraphicsImageRenderer(bounds: bounds)
      return renderer.image { context in
        layer.render(in: context.cgContext)
      }
    }

    public func snapshotImage() -> UIImage {
      UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
      drawHierarchy(in: bounds, afterScreenUpdates: true)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image ?? UIImage()
    }
  }

#endif
