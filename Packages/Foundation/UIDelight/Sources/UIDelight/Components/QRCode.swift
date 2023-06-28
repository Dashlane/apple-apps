#if canImport(UIKit)
import Foundation
import SwiftUI
import Foundation
import UIKit
import CoreImage.CIFilterBuiltins

public struct QRCode: View {

    let url: String
    let backgroundColor: UIColor
    let color: UIColor

    public init(url: String, backgroundColor: UIColor, color: UIColor) {
        self.url = url
        self.backgroundColor = backgroundColor
        self.color = color
    }

    public var body: some View {
        QRView(url: url, backgroundColor: backgroundColor, color: color)
    }
}

struct QRView: UIViewRepresentable {

    let logo: UIImage?
    let url: String
    let backgroundColor: CIColor
    let color: CIColor
    let size: CGSize

    init(url: String, logo: UIImage? = nil, backgroundColor: UIColor, color: UIColor, size: CGSize = .init(width: 250, height: 250)) {
        self.logo = logo
        self.url = url
        self.backgroundColor = CIColor(color: backgroundColor)
        self.color = CIColor(color: color)
        self.size = size
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}

    func makeUIView(context: Context) -> UIImageView {
        return UIImageView.init(image: qrImage())
    }

    func qrImage() -> UIImage? {

        guard var image  = createCIImage() else { return nil}

                let scaleW = self.size.width/image.extent.size.width
        let scaleH = self.size.height/image.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleW, y: scaleH)
        image = image.transformed(by: transform)

                if let logo = logo, let newImage =  addLogo(image: image, logo: logo) {
           image = newImage
        }

                if let colorImgae = updateColor(image: image) {
            image = colorImgae
        }

        return UIImage(ciImage: image)
    }

    private func createCIImage() -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.utf8)
        return filter.outputImage
    }

    private func addLogo(image: CIImage, logo: UIImage) -> CIImage? {

        let combinedFilter = CIFilter.sourceOverCompositing()
        guard let logo = logo.cgImage else {
            return image
        }
        let ciLogo = CIImage(cgImage: logo)
        let centerTransform = CGAffineTransform(translationX: image.extent.midX - (ciLogo.extent.size.width / 2), y: image.extent.midY - (ciLogo.extent.size.height / 2))
        combinedFilter.inputImage = ciLogo.transformed(by: centerTransform)
        combinedFilter.backgroundImage = image
        return combinedFilter.outputImage
    }

    private func updateColor(image: CIImage) -> CIImage? {
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = image
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter.outputImage
    }
}

struct QRCode_Previews: PreviewProvider {
    static var previews: some View {
        QRCode(url: "_", backgroundColor: .cyan, color: .green)
    }
}

#endif
