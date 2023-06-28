import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight
import UIComponents

public struct ImportInformationView: View {

    public enum Action {
        case importCompleted(data: Data)
        case nextInfo
        case close
        case done
    }

    let model: ImportInformationViewModel
    let action: (@MainActor (Action) -> Void)?
    @Binding var isLoading: Bool

    @State
    private var showDocumentPicker = false

    @State
    private var showConfirmationPopup = false

    private var kind: ImportFlowKind {
        return model.kind
    }

    private var step: ImportInformationViewModel.Step {
        return model.step
    }

    public var body: some View {
        VStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        if let image = kind.image(for: step) {
                            image
                                .padding(.bottom, 73)
                        }
                        information
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .fiberAccessibilityElement(children: .combine)
                }
            }
            ctaButtons
                .padding(.bottom, 30)
        }
        .frame(maxHeight: .infinity)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationBarStyle(.transparent(tintColor: .ds.text.brand.standard, titleColor: nil))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                doneButton
            }
        }
        .reportPageAppearance(model.pageToReport)
        .documentPicker(open: kind.contentTypes, isPresented: $showDocumentPicker) { data in
            data.map { self.action?(.importCompleted(data: $0)) }
        }
        .alert(isPresented: $showConfirmationPopup) {
            confirmationPopup
        }
    }

}

private extension ImportInformationView {

    @ViewBuilder
    var doneButton: some View {
        if case .extension = step {
            Button(L10n.Core.m2WImportFromChromeImportScreenDone) {
                self.showConfirmationPopup = true
            }
            .foregroundColor(.ds.text.brand.standard)
        }
    }

    var confirmationPopup: Alert {
        Alert(
            title: Text(L10n.Core.m2WImportFromChromeConfirmationPopupTitle),
            primaryButton: .default(Text(L10n.Core.m2WImportFromChromeConfirmationPopupYes)) {
                Task { @MainActor in
                    self.action?(.done)
                }
            },
            secondaryButton: .cancel(Text(L10n.Core.m2WImportFromChromeConfirmationPopupNo))
        )
    }

    @ViewBuilder
    var information: some View {
        switch (kind, step) {
        case (.chrome, .extension):
            VStack {
                styledDescription
                Spacer()
                    .frame(height: 8)
                styledTitle
            }
        default:
            VStack {
                styledTitle
                Spacer()
                    .frame(height: 8)
                styledDescription
            }
        }
    }

    @ViewBuilder
    var styledTitle: some View {
        if let title = kind.title(for: step) {
            Text(title)
                .frame(maxWidth: 400)
                .font(DashlaneFont.custom(28, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var styledDescription: some View {
        if let description = kind.description(for: step) {
            Text(description)
                .frame(maxWidth: 400)
                .font(.body.weight(.light))
                .foregroundColor(.ds.text.neutral.standard)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var ctaButtons: some View {
        switch kind {
        case .dash:
            ctaButtonsForDash
        case .keychain:
            ctaButtonsForKeychain
        case .chrome:
            ctaButtonsForChrome
        case .lastpass:
            ctaButtonsForLastpass
        }
    }

    @ViewBuilder
    var ctaButtonsForDash: some View {
        if case .intro = step {
            Button(L10n.Core.m2WImportFromDashIntroScreenBrowse) {
                self.showDocumentPicker = true
                model.reportImportStarted()
            }
            .roundedButtonLayout(.fill)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    var ctaButtonsForLastpass: some View {
        if case .intro = step {
            VStack {
                RoundedButton(L10n.Core.m2WImportFromKeychainIntroScreenBrowse) {
                    self.showDocumentPicker = true
                    model.reportImportStarted()
                }
                .roundedButtonLayout(.fill)
                .roundedButtonDisplayProgressIndicator(isLoading)
                .disabled(isLoading)
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    var ctaButtonsForKeychain: some View {
        if case .intro = step {
            VStack {
                RoundedButton(L10n.Core.m2WImportFromKeychainIntroScreenBrowse) {
                    self.showDocumentPicker = true
                    model.reportImportStarted()
                }
                .roundedButtonLayout(.fill)
                .padding(.horizontal, 16)

                Button(L10n.Core.m2WImportFromKeychainIntroScreenNotExported) {
                    Task { @MainActor in
                        self.action?(.nextInfo)
                    }
                }
                .buttonStyle(BorderlessActionButtonStyle())
                .foregroundColor(.ds.text.brand.standard)
            }
        } else if case .instructions = step {
            VStack {
                RoundedButton(L10n.Core.m2WImportFromKeychainURLScreenBrowse) {
                    self.showDocumentPicker = true
                    model.reportImportStarted()
                }
                .roundedButtonLayout(.fill)
                .padding(.horizontal, 16)

                Button(L10n.Core.m2WImportFromKeychainURLScreenClose) {
                    Task { @MainActor in
                        self.action?(.close)
                    }
                }
                .buttonStyle(BorderlessActionButtonStyle())
                .foregroundColor(.ds.text.brand.standard)
            }
        }
    }

    @ViewBuilder
    var ctaButtonsForChrome: some View {
        if case .intro = step {
            RoundedButton(L10n.Core.m2WImportFromChromeIntoScreenCTA) {
                Task { @MainActor in
                    self.action?(.nextInfo)
                }
            }
            .roundedButtonLayout(.fill)
            .padding(.horizontal, 16)
        } else if case .instructions = step {
            RoundedButton(L10n.Core.m2WImportFromChromeURLScreenCTA) {
                Task { @MainActor in
                    self.action?(.nextInfo)
                }
            }
            .roundedButtonLayout(.fill)
            .padding(.horizontal, 16)
        }
    }

}

fileprivate extension ImportFlowKind {
    func image(for step: ImportInformationViewModel.Step) -> Image? {
        switch (self, step) {
        case (.dash, .intro):
            return Image(asset: Asset.dashImport)
        case (.keychain, .intro):
            return Image(asset: Asset.keychainImport)
        case (.keychain, .instructions):
            return Image(asset: Asset.keychainInstructions)
        case (.lastpass, .intro):
            return Image(asset: Asset.lastpassImport)
        case (.chrome, .intro):
            return Image(asset: Asset.chromeImport)
        case (.chrome, .instructions):
            return Image(asset: Asset.m2wConnect)
        case (.chrome, .extension):
            return Image(asset: Asset.chromeInstructions)
        default:
            return nil
        }
    }

    func title(for step: ImportInformationViewModel.Step) -> String? {
        switch (self, step) {
        case (.dash, .intro):
            return L10n.Core.m2WImportFromDashIntroScreenPrimaryTitle
        case (.keychain, .intro):
            return L10n.Core.m2WImportFromKeychainIntroScreenPrimaryTitle
        case (.lastpass, .intro):
            return L10n.Core.importFromLastpassIntroTitle
        case (.keychain, .instructions):
            return L10n.Core.m2WImportFromKeychainURLScreenPrimaryTitle
        case (.chrome, .intro):
            return L10n.Core.m2WImportFromChromeIntroScreenPrimaryTitle
        case (.chrome, .instructions):
            return L10n.Core.m2WImportFromChromeURLScreenPrimaryTitle
        case (.chrome, .extension):
            return L10n.Core.m2WImportFromChromeImportScreenPrimaryTitle
        default:
            return nil
        }
    }

    func description(for step: ImportInformationViewModel.Step) -> String? {
        switch (self, step) {
        case (.dash, _):
            return L10n.Core.m2WImportFromDashIntroScreenSecondaryTitle
        case (.keychain, .intro):
            return L10n.Core.m2WImportFromKeychainIntroScreenSecondaryTitle
        case (.lastpass, .intro):
            return L10n.Core.importFromLastpassIntroDescription
        case (.keychain, _):
            return L10n.Core.m2WImportFromKeychainURLScreenSecondaryTitle
        case (.chrome, .intro):
            return L10n.Core.m2WImportFromChromeIntoScreenSecondaryTitle
        case (.chrome, .extension):
            return L10n.Core.m2WImportFromChromeImportScreenSecondaryTitle
        default:
            return nil
        }
    }

}

struct ImportInformationView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhone8, .iPhone11, .iPadPro])) {
            ImportInformationView(model: .dashMock, action: nil, isLoading: .constant(false))
            ImportInformationView(model: .keychainIntroMock, action: nil, isLoading: .constant(false))
            ImportInformationView(model: .keychainInstructionsMock, action: nil, isLoading: .constant(false))
            ImportInformationView(model: .chromeIntroMock, action: nil, isLoading: .constant(false))
            ImportInformationView(model: .chromeInstrutionsMock, action: nil, isLoading: .constant(false))
            ImportInformationView(model: .chromeExtensionMock, action: nil, isLoading: .constant(false))
        }
    }
}
