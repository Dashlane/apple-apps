import CorePremium
import SwiftUI
import UserTrackingFoundation

struct ExportCSVSettingsSection: View {
  @StateObject
  var viewModel: ExportCSVSettingsSectionModel

  @State
  var showExportView: Bool = false

  @Environment(\.toast)
  var toast

  init(viewModel: @autoclosure @escaping () -> ExportCSVSettingsSectionModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    Section {
      ExportVaultButton(
        title: L10n.Localizable.Settings.Export.Csv.exportButton,
        exportStatus: viewModel.exportStatus
      ) {
        showExportView = true
      }
      .sheet(isPresented: $showExportView) {
        ExportCSVModalView(csv: viewModel.csv())
      }
    } footer: {
      Text(L10n.Localizable.Settings.Export.Csv.footer).textStyle(.body.helper.regular)
    }
    .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
  }
}

#Preview {
  List {
    ExportCSVSettingsSection(viewModel: .mock(status: .Mock.freeTrial))
  }.listStyle(.ds.insetGrouped)
}
