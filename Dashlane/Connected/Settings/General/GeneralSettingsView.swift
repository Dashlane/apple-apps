import SwiftUI
import SwiftTreats
import DashlaneAppKit
import CoreSettings
import UIDelight
import ImportKit
import CoreFeature

struct GeneralSettingsView: View {

    enum Action {
        case displayImportFlow(DashImportFlowViewModel)
    }

    @StateObject
    var viewModel: GeneralSettingsViewModel
    var action: (Action) -> Void

    @FeatureState(.prideIcons)
    var isPrideIconsEnabled: Bool

    @FeatureState(.dashImport)
    var isDashImportEnabled: Bool

    @FeatureState(.mobileSecureExport)
    var isDashExportEnabled: Bool

    @State
    var showDocumentPicker = false

    init(viewModel: @autoclosure @escaping () -> GeneralSettingsViewModel, action: @escaping(Action) -> Void) {
        _viewModel = .init(wrappedValue: viewModel())
        self.action = action
    }

    var body: some View {
        List {
            Section(header: Text(L10n.Localizable.kwSettingsClipboardSection), footer: Text(L10n.Localizable.kwSettingsClipboardFooter)) {
                Toggle(L10n.Localizable.kwSetClipboardExpiration(Float(GeneralSettingsViewModel.pasteboardExpirationDelay) / 60), isOn: $viewModel.isClipboardExpirationEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                Toggle(L10n.Localizable.kwUseUniversalClipboard, isOn: $viewModel.isUniversalClipboardEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }

            if !Device.isMac {
                Section(footer: Text(L10n.Localizable.kwIosIntegrationSettingsSectionFooter)) {
                    Toggle(L10n.Localizable.kwIosIntegrationSettingsSwitchTitle, isOn: $viewModel.isAdvancedSystemIntegrationEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
            }

            Section(footer: Text(L10n.Localizable.clipboardSettingsShouldBeOverriddenFooter)) {
                Toggle(L10n.Localizable.clipboardSettingsShouldBeOverridden, isOn: $viewModel.isClipboardOverridden)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }

            if !Device.isMac {
                if isDashImportEnabled {
                    Section(footer: Text(L10n.Localizable.kwSettingsRestoreFooter)) {
                        Button(action: {
                            viewModel.activityReporter.reportPageShown(.importBackupfile)
                            showDocumentPicker = true
                        }, label: {
                            Text(L10n.Localizable.kwSettingsRestoreSection)
                                .foregroundColor(.primary)
                        })
                    }
                }

                if isDashExportEnabled {
                    Section {
                        SecureArchiveSectionContent(exportSecureArchiveViewModelFactory: viewModel.exportSecureArchiveViewModelFactory)
                    }
                }

                Section {
                    NavigationLink(L10n.Localizable.alternateIconSettingsTitle) {
                        AlternateIconSwitcherView(iconSettings: AlternateIconNames(categories: isPrideIconsEnabled ? [.brand, .pride] : [.brand]))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.Localizable.kwGeneral)
        .reportPageAppearance(.settingsGeneral)
        .onReceive(viewModel.displayImportFlow) { _ in
            action(.displayImportFlow(viewModel.importFlowViewModel))
        }
        .documentPicker(open: viewModel.importContentTypes, isPresented: $showDocumentPicker) { data in
            data.map { viewModel.handleImportFile($0) }
        }
        .sheet(isPresented: $viewModel.showImportPasswordView) {
            DashImportPasswordView(model: viewModel.importFlowViewModel.importViewModel,
                                   action: viewModel.importPasswordViewAction)
        }
        .hideTabBar()
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GeneralSettingsViewModel.mock
        GeneralSettingsView(viewModel: viewModel, action: { _ in })
    }
}
