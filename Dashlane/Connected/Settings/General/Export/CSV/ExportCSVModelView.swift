import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UserTrackingFoundation

struct ExportCSVModalView: View {
  @Environment(\.toast)
  var toast

  @Environment(\.dismiss)
  var dismiss

  @Environment(\.openURL)
  var openURL

  @Environment(\.report)
  var report

  @State
  var isExporting: Bool = false

  @State
  var showError: Bool = false

  let csv: DashlaneCSVExport

  var body: some View {
    VStack(alignment: .leading) {
      header
      Spacer()
      actions
    }
    .padding(24)
    .fileExporter(isPresented: $isExporting, document: csv, defaultFilename: "Dashlane CSV") {
      result in
      if result.isSuccess {
        report?(
          UserEvent.ExportData(
            backupFileType: .csv, exportDataStatus: .success, exportDataStep: .success,
            exportDestination: .sourceOther))

        dismiss()

        toast(
          L10n.Localizable.Settings.Export.Csv.ExportView.successToast,
          image: .ds.feedback.success.outlined)
      } else {
        showError = true
      }
    }
    .alert(L10n.Localizable.Settings.Export.Csv.ExportView.errorTitle, isPresented: $showError) {
      Button(CoreL10n.kwButtonOk, role: .cancel) {

      }
    }
    .onAppear {
      report?(
        UserEvent.ExportData(
          backupFileType: .csv, exportDataStatus: .start, exportDataStep: .selectExportDestination,
          exportDestination: .sourceOther))
    }
  }

  @ViewBuilder
  var header: some View {
    VStack(alignment: .leading, spacing: 24) {
      DS.ExpressiveIcon(.ds.csv.outlined)
        .controlSize(.extraLarge)
        .style(mood: .brand, intensity: .quiet)

      Text(L10n.Localizable.Settings.Export.Csv.ExportView.title)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(L10n.Localizable.Settings.Export.Csv.ExportView.description)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
    }

    Button(L10n.Localizable.Settings.Export.Csv.ExportView.helpLink) {
      openURL(URL(string: "_")!)
    }
    .buttonStyle(.externalLink)
  }

  @ViewBuilder
  var actions: some View {
    Button {
      isExporting = true
    } label: {
      Label(
        L10n.Localizable.Settings.Export.Csv.ExportView.exportButton, icon: .ds.download.outlined)
    }
    .buttonStyle(.designSystem(.iconLeading))
    .style(mood: .brand, intensity: .catchy)

    Button(CoreL10n.cancel, role: .cancel) {
      dismiss()
    }
    .buttonStyle(.designSystem(.titleOnly))
    .style(mood: .brand, intensity: .quiet)
  }
}

#Preview {
  ExportCSVModalView(
    csv: .init(
      credentials: [],
      secureNotes: [],
      creditCards: [],
      bankAccounts: [],
      idCards: [],
      passports: [],
      drivingLicences: [],
      socialSecurityInformation: [],
      identities: [],
      emails: [],
      phones: [],
      addresses: [],
      companies: [],
      websites: [],
      wifi: []))
}
