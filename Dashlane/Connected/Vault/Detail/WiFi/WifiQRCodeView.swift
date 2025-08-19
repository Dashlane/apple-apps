import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

struct WifiQRCodeView: View {
  @Environment(\.dismiss)
  var dismiss

  @StateObject
  var model: WifiQRCodeViewModel

  @State private var contentHeight: CGFloat?
  @State private var previousBrightness: CGFloat = 1

  @ScaledMetric private var cornerRadius = 16

  init(model: @escaping @autoclosure () -> WifiQRCodeViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    VStack(spacing: 40) {
      VStack(spacing: 8) {
        Text(model.item.displayTitle)
          .textStyle(.title.section.medium)
          .lineLimit(nil)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        Text(CoreL10n.WiFi.DetailView.Qrcode.subtitle)
          .textStyle(.body.standard.regular)
          .lineLimit(nil)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .fixedSize(horizontal: false, vertical: true)

      QRCode(url: model.item.qrCodeURL)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .padding(40)
        .background {
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.ds.background.alternate)
        }

      Button(CoreL10n.WiFi.DetailView.Qrcode.done) {
        dismiss()
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 24)
    .padding(.top, 40)
    .padding(.bottom, 32)
    .onGeometryChange(
      for: CGFloat.self,
      of: { $0.size.height },
      action: { contentHeight = $0 }
    )
    .presentationBackground(Color.ds.container.agnostic.neutral.supershy)
    .presentationDetents(contentHeight.flatMap({ [.height($0)] }) ?? [])
    .presentationCornerRadius(cornerRadius)
    .onAppear {
      set(brightness: 1)
    }
    .onDisappear {
      set(brightness: previousBrightness)
    }
  }

  private func set(brightness: CGFloat) {
    #if os(iOS)
      previousBrightness = UIScreen.main.brightness
      UIScreen.main.brightness = brightness
    #endif
  }
}

#Preview {
  WifiQRCodeView(
    model: .mock(
      service: .mock(item: .init(ssid: "Wifi network", encryptionType: .unsecured), mode: .viewing))
  )
}
