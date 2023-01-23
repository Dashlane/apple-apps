import SwiftUI
import DesignSystem
import SwiftTreats
import UIComponents

struct SSOEnableBiometricsOrPinView: View {

    @StateObject
    var viewModel: SSOEnableBiometricsOrPinViewModel

    @ScaledMetric
    private var fontSize: CGFloat = 24

    @ScaledMetric
    private var imageSize: CGFloat = 67

    @Environment(\.dismiss) var dismiss

    let completion: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                content
                Spacer()
                buttons
            }
            .padding()
            .background(Color.ds.background.default)
            .toolbar {
                ToolbarItem {
                    Button(L10n.Localizable.kwSkip) {
                        dismiss()
                        completion()
                    }
                }
            }
            .onAppear {
                viewModel.markAsViewed()
            }
            .overFullScreen(isPresented: $viewModel.choosePinCode) {
                PinCodeSelection(model: viewModel.makePinCodeViewModel())
            }
            .onReceive(viewModel.dismiss) { _ in
                dismiss()
                completion()
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image.ds.lock.outlined
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.ds.text.brand.standard)
            Text(titleText)
                .font(DashlaneFont.custom(fontSize, .medium).font)
                .foregroundColor(.ds.text.neutral.standard)
            Text(contentText)
                .font(.body)
                .foregroundColor(.ds.text.neutral.quiet)
        }
    }

    var buttons: some View {
        VStack(spacing: 8) {
            mainButton
            secondaryButton
        }
        .roundedButtonLayout(.fill)

    }

    @ViewBuilder
    var mainButton: some View {
        if viewModel.isBiometryAvailable {
            RoundedButton(L10n.Localizable.ssoUseBiometricsButton(Device.currentBiometryDisplayableName)) {
                viewModel.enableBiometry()
            }
        } else {
            RoundedButton(L10n.Localizable.ssoUsePinCodeButton) {
                viewModel.choosePinCode = true
            }
        }
    }

    @ViewBuilder
    var secondaryButton: some View {
        if viewModel.isBiometryAvailable {
            RoundedButton(L10n.Localizable.ssoUsePinCodeButton) {
                viewModel.choosePinCode = true
            }
            .style(intensity: .supershy)
        }
    }
}

extension SSOEnableBiometricsOrPinView {

    var titleText: String {
        viewModel.isBiometryAvailable ? L10n.Localizable.ssoUseBiometricsTitle : L10n.Localizable.ssoUsePinCodeTitle
    }

    var contentText: String {
        viewModel.isBiometryAvailable ? L10n.Localizable.ssoUseBiometricsContent(Device.currentBiometryDisplayableName) :  L10n.Localizable.ssoUsePinCodeContent
    }
}

struct SSOEnableBiometricsOrPinView_Previews: PreviewProvider {
    static var previews: some View {
        SSOEnableBiometricsOrPinView(viewModel: .mock, completion: {})
    }
}
