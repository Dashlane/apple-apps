import SwiftUI
import SwiftTreats
import DashlaneAppKit
import CoreSettings
import UIDelight
import ImportKit
import CoreFeature
import DesignSystem
import CoreLocalization

struct GeneralSettingsView: View {
    @StateObject
    var viewModel: GeneralSettingsViewModel

    @FeatureState(.prideIcons)
    var isPrideIconsEnabled: Bool

    @FeatureState(.dashImport)
    var isDashImportEnabled: Bool

    @FeatureState(.mobileSecureExport)
    var isDashExportEnabled: Bool

    @State
    var showDocumentPicker = false

    @State
    var showImportFlow = false

    init(viewModel: @autoclosure @escaping () -> GeneralSettingsViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        List {
            Section(
                header: Text(L10n.Localizable.kwSettingsClipboardSection).textStyle(.title.supporting.small),
                footer: Text(L10n.Localizable.kwSettingsClipboardFooter).textStyle(.body.helper.regular)
            ) {
                DS.Toggle(
                    L10n.Localizable.kwSetClipboardExpiration(
                        Float(GeneralSettingsViewModel.pasteboardExpirationDelay) / 60
                    ),
                    isOn: $viewModel.isClipboardExpirationEnabled
                )
                DS.Toggle(
                    L10n.Localizable.kwUseUniversalClipboard,
                    isOn: $viewModel.isUniversalClipboardEnabled
                )
            }

            if !Device.isMac {
                Section(
                    footer: Text(L10n.Localizable.kwIosIntegrationSettingsSectionFooter).textStyle(.body.helper.regular)
                ) {
                    DS.Toggle(
                        L10n.Localizable.kwIosIntegrationSettingsSwitchTitle,
                        isOn: $viewModel.isAdvancedSystemIntegrationEnabled
                    )
                }
            }

            Section(footer: Text(L10n.Localizable.clipboardSettingsShouldBeOverridenFooter)) {
                DS.Toggle(L10n.Localizable.clipboardSettingsShouldBeOverriden, isOn: $viewModel.isClipboardOverridden)
            }

            if !Device.isMac {
                if isDashImportEnabled {
                    Section(footer: Text(L10n.Localizable.kwSettingsRestoreFooter).textStyle(.body.helper.regular)) {
                        Button(action: {
                            viewModel.activityReporter.reportPageShown(.importBackupfile)
                            showDocumentPicker = true
                        }, label: {
                            Text(L10n.Localizable.kwSettingsRestoreSection)
                                .foregroundColor(.ds.text.neutral.standard)
                                .textStyle(.body.standard.regular)
                        })
                    }
                }

                if isDashExportEnabled {
                    Section {
                        SecureArchiveSectionContent(exportSecureArchiveViewModelFactory: viewModel.exportSecureArchiveViewModelFactory)
                    }
                }

                Section {
                    NavigationLink {
                        AlternateIconSwitcherView(iconSettings: AlternateIconNames(categories: isPrideIconsEnabled ? [.brand, .pride] : [.brand]))
                    } label: {
                        Text(L10n.Localizable.alternateIconSettingsTitle)
                            .textStyle(.body.standard.regular)
                            .foregroundColor(.ds.text.neutral.standard)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.Localizable.kwGeneral)
        .reportPageAppearance(.settingsGeneral)
        .documentPicker(open: viewModel.importContentTypes, isPresented: $showDocumentPicker) { data in
            data.map { viewModel.handleImportFile($0) }
        }
        .sheet(isPresented: $viewModel.showImportPasswordView) {
            DashImportPasswordView(model: viewModel.importFlowViewModel.importViewModel) { action in
                viewModel.importPasswordViewAction(action)
            }
        }
        .hideTabBar()
        .navigationDestination(isPresented: $viewModel.showImportFlow) {
            ImportFlowView(viewModel: viewModel.importFlowViewModel)
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GeneralSettingsViewModel.mock
        GeneralSettingsView(viewModel: viewModel)
    }
}
