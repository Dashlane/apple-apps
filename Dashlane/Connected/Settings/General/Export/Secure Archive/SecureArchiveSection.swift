import DesignSystem
import SwiftUI
import UserTrackingFoundation

struct SecureArchiveSection: View {
  @StateObject
  var viewModel: SecureArchiveSectionViewModel

  @Environment(\.report)
  var report

  @State
  var showExportView: Bool = false

  init(viewModel: @autoclosure @escaping () -> SecureArchiveSectionViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    Section {
      ExportVaultButton(
        title: L10n.Localizable.Settings.Export.DashArchive.exportButton,
        exportStatus: viewModel.exportStatus
      ) {
        showExportView = true

        report?(
          UserEvent.ExportData(
            backupFileType: .dash, exportDataStatus: .start,
            exportDataStep: .selectExportDestination, exportDestination: .sourceDash))
      }
      .fullScreenCover(isPresented: $showExportView) {
        ExportSecureArchiveView(viewModel: viewModel.makeExportSecureArchiveViewModel())
      }
    } footer: {
      Text(L10n.Localizable.Settings.Export.DashArchive.footer).textStyle(.body.helper.regular)
    }
    .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
  }
}

#Preview {
  List {
    SecureArchiveSection(viewModel: .mock(status: .Mock.freeTrial))
  }.listStyle(.ds.insetGrouped)
}
