import CoreImage
import DashTypes
import Foundation
import PDFKit
import SwiftUI
import UIDelight

struct OTPExport: Identifiable {
  let info: OTPInfo
  let qrCode: Image

  var id: Identifier {
    info.id
  }

  init(info: OTPInfo) {
    self.info = info
    if let cgImage = CIImage.makeQRCodeImage(
      url: info.configuration.otpURL.absoluteString, scale: 10)?.renderedCGImage()
    {
      self.qrCode = Image(cgImage, scale: 1, label: Text(""))
    } else {
      self.qrCode = Image(systemName: "square.slash.fill")
    }
  }
}

struct ExportList: View {
  let otps: [OTPExport]

  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 5, verticalSpacing: 20) {
      GridRow {
        Text("Service")
        Text("QRCode")
        Text("Recovery Codes")
      }
      .font(.system(size: 14))
      .foregroundStyle(.secondary)

      GridRow {
        Divider()
      }.gridCellColumns(3)

      ForEach(otps) { otp in
        GridRow {
          Text(otp.info.configuration.title)
            .font(.system(size: 14))

          otp.qrCode
            .resizable()
            .interpolation(.none)
            .aspectRatio(contentMode: .fit)
            .frame(width: 150.0, height: 150.0)

          if !otp.info.recoveryCodes.isEmpty {
            VStack(alignment: .leading) {
              Text(otp.info.recoveryCodes.joined(separator: "\n"))
                .font(.system(size: 11))
                .fixedSize()
            }
          }
        }

        GridRow {
          Divider()
        }.gridCellColumns(3)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(20)
  }
}

extension [OTPInfo] {
  @MainActor
  public func makePDF() throws -> URL {
    let renderURL = try URL.temporary()
    let exports = self.map {
      OTPExport(info: $0)
    }
    let list = ExportList(otps: exports)
      .frame(width: 800)

    let renderer = ImageRenderer(content: list)
    renderer.render(rasterizationScale: 2) { size, renderer in
      var mediaBox = CGRect(
        origin: .zero,
        size: .init(width: size.width, height: size.height)
      ).integral
      guard let consumer = CGDataConsumer(url: renderURL as CFURL),
        let pdfContext = CGContext(
          consumer: consumer,
          mediaBox: &mediaBox, nil)

      else {
        return
      }
      pdfContext.beginPDFPage(nil)
      pdfContext.interpolationQuality = .high
      renderer(pdfContext)
      pdfContext.endPDFPage()
      pdfContext.closePDF()
    }

    return renderURL
  }

  @MainActor
  public func makeImage() -> Image {
    let exports = self.map {
      OTPExport(info: $0)
    }
    let list = ExportList(otps: exports)
      .frame(width: 800)
    let renderer = ImageRenderer(content: list)
    if let renderedImage = renderer.uiImage {
      return Image(uiImage: renderedImage)
    } else {
      return Image("qrcode")
    }
  }
}

let otpInfos: [OTPInfo] = [
  .mock,
  .mockWithRecoveryCodes,
  .mock, .mockWithRecoveryCodes,
  .mock,
  .mockWithRecoveryCodes,
  .mockWithRecoveryCodes,
  .mock, .mockWithRecoveryCodes,
  .mock,
  .mockWithRecoveryCodes,
  .mock,
  .mockWithRecoveryCodes,
  .mockWithRecoveryCodes,
  .mock,
]

#Preview("QR Code") {
  OTPExport(info: otpInfos[0]).qrCode
    .resizable()
    .interpolation(.none)
    .aspectRatio(contentMode: .fit)
    .frame(width: 300.0, height: 300.0)
}

#Preview("View") {
  ScrollView {
    ExportList(
      otps: otpInfos.map {
        OTPExport(info: $0)
      }
    )
    .frame(width: 800)
  }
}

#Preview("PDF") {
  PDFKitView(document: try! PDFDocument(url: otpInfos.makePDF())!)
}

#Preview("Image") {
  ScrollView(.vertical) {
    otpInfos.makeImage()
      .resizable()
      .aspectRatio(contentMode: .fit)

  }
}

struct PDFKitView: UIViewRepresentable {
  let pdfDocument: PDFDocument

  init(document: PDFDocument) {
    self.pdfDocument = document
  }

  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    pdfView.document = pdfDocument
    pdfView.autoScales = true
    return pdfView
  }

  func updateUIView(_ pdfView: PDFView, context: Context) {
    pdfView.document = pdfDocument
  }
}

extension CIImage {
  func renderedCGImage() -> CGImage? {
    let context = CIContext(options: nil)
    return context.createCGImage(self, from: self.extent)
  }
}
