import Foundation
import SwiftUI
import UIComponents
import DesignSystem
import CoreLocalization
import UIDelight
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import LoginKit

struct AddNewDeviceView: View {

    @StateObject
    var model: AddNewDeviceViewModel

    @Environment(\.dismiss)
    var dismiss

    init(model: @autoclosure @escaping () -> AddNewDeviceViewModel) {
        _model = .init(wrappedValue: model())
    }

    var body: some View {
        ZStack {
            if model.isLoading {
                ProgressionView(state: $model.progressState)
            } else {
                navigationView
            }
        }
        .animation(.default, value: model.isLoading)
        .onReceive(model.dismissPublisher) {
            dismiss()
        }
        .fullScreenCover(isPresented: $model.showError) {
            FeedbackView(title: CoreLocalization.L10n.Core.deviceToDeviceLoginErrorTitle,
                         message: CoreLocalization.L10n.Core.deviceToDeviceLoginErrorMessage,
                         primaryButton: (CoreLocalization.L10n.Core.deviceToDeviceLoginErrorRetry, { model.showError = false }),
                         secondaryButton: (CoreLocalization.L10n.Core.cancel, {
                model.showError = false
                dismiss()}))
        }
    }

    var navigationView: some View {
        NavigationView {
            ZStack {
                mainView
                overlayView
            }
            .navigationBarStyle(.transparent)
            .navigationTitle(L10n.Localizable.addNewDeviceSettingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(CoreLocalization.L10n.Core.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.ds.text.brand.standard)
                }
            }
            .animation(.default, value: model.showScanner)
            .sheet(isPresented: $model.showScanner) {
                scanView
            }
        }
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(L10n.Localizable.addNewDeviceTitle)
                .foregroundColor(.ds.text.neutral.catchy)
                .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
            InstructionsCardView(cardContent: [L10n.Localizable.addNewDeviceMessage1,
                                               L10n.Localizable.addNewDeviceMessage2,
                                               L10n.Localizable.addNewDeviceMessage3])
            Spacer()
        }.padding(24)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }

    var overlayView: some View {
        VStack {
            Spacer()
            RoundedButton(L10n.Localizable.addNewDeviceScanCta, action: {
                model.showScanner = true
            })
            .style(mood: .brand, intensity: .catchy)
            .roundedButtonLayout(.fill)
        }.padding(24)
    }

    var scanView: some View {
        ScanQrCodeView { qrcode in
            model.didScanQRCode(qrcode)
        }
    }
}

struct AddNewDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewDeviceView(model: .mock)
    }
}
