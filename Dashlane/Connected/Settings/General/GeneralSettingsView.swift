import CoreFeature
import CoreLocalization
import DesignSystem
import ImportKit
import SwiftTreats
import SwiftUI
import UserTrackingFoundation
import VaultKit

struct GeneralSettingsView: View {
  @StateObject
  var viewModel: GeneralSettingsViewModel

  @FeatureState(.prideIcons)
  var isPrideIconsEnabled: Bool

  @FeatureState(.dashImport)
  var isDashImportEnabled: Bool

  @FeatureState(.mobileSecureExport)
  var isDashExportEnabled: Bool

  @FeatureState(.removeDuplicates)
  var isRemoveDuplicatesEnabled: Bool

  @State
  var showDocumentPicker = false

  @State
  var showImportFlow = false

  @State
  var showAlternateIconSwitcher = false

  @State
  var showDeduplicationSheet = false

  init(viewModel: @autoclosure @escaping () -> GeneralSettingsViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    List {
      Section(
        header: Text(L10n.Localizable.kwSettingsClipboardSection).textStyle(
          .title.supporting.small),
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
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      if !Device.is(.mac) {
        Section(
          footer: Text(L10n.Localizable.kwIosIntegrationSettingsSectionFooter).textStyle(
            .body.helper.regular)
        ) {
          DS.Toggle(
            L10n.Localizable.kwIosIntegrationSettingsSwitchTitle,
            isOn: $viewModel.isAdvancedSystemIntegrationEnabled
          )
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      if #unavailable(iOS 18.0) {
        Section(footer: Text(L10n.Localizable.clipboardSettingsShouldBeOverridenFooter)) {
          DS.Toggle(
            L10n.Localizable.clipboardSettingsShouldBeOverriden,
            isOn: $viewModel.isClipboardOverridden)
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      if isRemoveDuplicatesEnabled {
        Section(
          footer: Text("Remove duplicate items in your Dashlane vault").textStyle(
            .body.helper.regular)
        ) {
          Button(
            action: {
              showDeduplicationSheet = true
            },
            label: {
              Text("Remove duplicates")
                .foregroundStyle(Color.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
            })
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      if isDashImportEnabled && !Device.is(.mac) {
        Section(
          footer: Text(L10n.Localizable.kwSettingsRestoreFooter).textStyle(.body.helper.regular)
        ) {
          Button(
            action: {
              viewModel.activityReporter.report(
                UserEvent.ImportData(
                  backupFileType: .dash, importDataStatus: .start, importDataStep: .selectFile,
                  importSource: .sourceDash, isDirectImport: false))

              viewModel.activityReporter.reportPageShown(.importBackupfile)

              showDocumentPicker = true
            },
            label: {
              Text(L10n.Localizable.kwSettingsRestoreSection)
                .foregroundStyle(Color.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
            })
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      ExportCSVSettingsSection(viewModel: viewModel.exportCSVSettingsSectionModelFactory.make())

      if isDashExportEnabled && !Device.is(.mac) {
        SecureArchiveSection(viewModel: viewModel.secureArchiveSectionViewModelFactory.make())
      }

      if !Device.is(.mac) {
        Section {
          Button {
            showAlternateIconSwitcher = true
          } label: {
            Text(L10n.Localizable.alternateIconSettingsTitle)
              .textStyle(.body.standard.regular)
              .foregroundStyle(Color.ds.text.neutral.standard)
          }
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }
    }
    .listStyle(.ds.insetGrouped)
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
    .navigationDestination(isPresented: $viewModel.showImportFlow) {
      if viewModel.showImportFlow {
        ImportFlowView(viewModel: viewModel.importFlowViewModel)
      }
    }
    .sheet(isPresented: $showAlternateIconSwitcher) {
      AlternateIconSwitcherView(model: .init(showPrideIcon: isPrideIconsEnabled))
    }
    .sheet(
      isPresented: $showDeduplicationSheet,
      content: {
        DuplicateItemsView(viewModel: viewModel.duplicateItemsViewModelFactory.make())
      }
    )
    .toolbar(.hidden, for: .tabBar)
  }
}

struct GeneralSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = GeneralSettingsViewModel.mock(status: .Mock.free)
    GeneralSettingsView(viewModel: viewModel)
      .environment(
        \.enabledFeatures,
        [
          .dashImport,
          .mobileSecureExport,
        ])
  }
}
