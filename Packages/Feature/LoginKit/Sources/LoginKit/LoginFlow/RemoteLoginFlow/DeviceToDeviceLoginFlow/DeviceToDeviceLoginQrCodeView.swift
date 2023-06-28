import Foundation
import SwiftUI
import DashTypes
import CoreImage.CIFilterBuiltins
import UIComponents
import CoreLocalization
import UIDelight

#if canImport(UIKit)
struct DeviceToDeviceLoginQrCodeView: View {

    @StateObject
    var model: DeviceToDeviceLoginQrCodeViewModel

    @State
    var progressState: ProgressionState = .inProgress("")
    @State
    var showHelp = false

    public init(model: @autoclosure @escaping () -> DeviceToDeviceLoginQrCodeViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        ZStack {
            if let url = model.qrCodeUrl {
                qrcodeView(url: url)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(L10n.Core.deviceToDeviceHelpCta) {
                                showHelp = true
                            }
                            .foregroundColor(.ds.text.brand.standard)
                        }
                    }
            } else if model.inProgress {
                ProgressionView(state: $model.progressState)
            }
        }
        .animation(.default, value: model.qrCodeUrl)
        .frame(maxWidth: .infinity)
        .background(.ds.background.alternate.ignoresSafeArea())
        .navigationBarStyle(.transparent)
        .loginAppearance()
        .fullScreenCover(item: $model.presentedItem) { item in
            switch item {
            case .error:
                FeedbackView(title: L10n.Core.deviceToDeviceLoginErrorTitle, message: L10n.Core.deviceToDeviceLoginErrorMessage, primaryButton: (L10n.Core.deviceToDeviceLoginErrorRetry, { model.retry() }), secondaryButton: (CoreLocalization.L10n.Core.cancel, {
                    model.presentedItem = nil
                    model.cancel()}))
            case let .recoveryFlow(accountInfo):
                AccountRecoveryKeyLoginFlow(model: model.makeAccountRecoveryKeyLoginFlowModel(accountInfo: accountInfo))
            }

        }
    }

    @ViewBuilder
    func qrcodeView(url: String) -> some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Core.deviceToDeviceQrcodeTitle)
                    .foregroundColor(.ds.text.neutral.catchy)
                    .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
                    .multilineTextAlignment(.leading)
                    .padding(24)
                Spacer()
            }
            VStack(alignment: .center) {
                Spacer()
                QRCode(url: url, backgroundColor: .ds.background.alternate, color: .ds.text.neutral.catchy)
                    .frame(width: 200, height: 200)
                Spacer()
                if let info = model.accountRecoveryInfo, info.isEnabled {
                    Button(action: {
                        model.presentedItem = .recoveryFlow(info)
                    }, label: {
                        Text(L10n.Core.forgotMpSheetRecoveryActionTitle)
                    })
                }
            }
        }
        .background(.ds.background.alternate.ignoresSafeArea())
            .sheet(isPresented: $showHelp) {
                DeviceToDeviceLoginHelpView()
            }

    }
}

extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)

    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
}

struct DeviceToDeviceLoginQrCodeView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceToDeviceLoginQrCodeView(model: DeviceToDeviceLoginQrCodeViewModel(loginHandler: .mock, apiClient: .fake, sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()), accountRecoveryKeyLoginFlowModelFactory: .init({ _, _, _, _  in
                .mock
        }), completion: {_ in}))
    }
}
#endif
