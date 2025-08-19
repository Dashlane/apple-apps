import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI
import UIKit

public struct QRCode: View {
  @StateObject
  private var model: QRCodeModel = .init()

  let url: String

  public init(url: String) {
    self.url = url
  }

  public var body: some View {
    ZStack {
      Rectangle()
        .fill(.foreground)
        .mask {
          if let mask = model.mask {
            mask
              .resizable()
              .interpolation(.none)
              .aspectRatio(contentMode: .fit)
          }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    .task(id: url) {
      model.generate(for: url)
    }
  }
}

private class QRCodeModel: ObservableObject {

  @Published
  var mask: Image?

  private func makeCIImage(url: String) -> CIImage? {
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(url.utf8)
    return filter.outputImage
  }

  func generate(for url: String) {
    let ciImage = CIImage.makeQRCodeImage(url: url, scale: 1)?
      .colorUpdated(with: .white, background: .clear)
    let ciContext = CIContext()

    guard let ciImage,
      let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
    else {
      mask = nil
      return
    }

    mask = .init(decorative: cgImage, scale: 1)
  }
}

extension CIImage {
  public static func makeQRCodeImage(url: String, scale: CGFloat) -> CIImage? {
    let qrCodeGenerator = CIFilter.qrCodeGenerator()
    qrCodeGenerator.message = Data(url.utf8)
    let ciImage = qrCodeGenerator.outputImage
    let scaledImage = ciImage?.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    return scaledImage
  }
}

extension CIImage {
  fileprivate func colorUpdated(with color: CIColor, background: CIColor) -> CIImage? {
    let colorFilter = CIFilter.falseColor()
    colorFilter.inputImage = self
    colorFilter.setValue(color, forKey: "inputColor0")
    colorFilter.setValue(background, forKey: "inputColor1")
    return colorFilter.outputImage
  }
}

struct QRCode_Previews: PreviewProvider {
  static var previews: some View {
    QRCode(url: "_")
      .foregroundStyle(.cyan.gradient.shadow(.inner(radius: 6)))
      .background(.yellow)
  }
}
