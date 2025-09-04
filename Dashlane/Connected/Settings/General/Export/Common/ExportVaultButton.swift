import CorePremium
import SwiftUI

struct ExportVaultButton: View {
  let title: String
  let exportStatus: ExportVaultStatus
  let export: () -> Void

  @Environment(\.accessControl) private var accessControl
  @State private var showExportView = false
  @State private var showExportOnlyPersonalDataAlert = false
  @State private var showExportDisabledAlert = false

  var body: some View {
    Button {
      switch exportStatus {
      case .limited:
        accessControl.requestAccess(for: .export) { granted in
          guard granted else {
            return
          }

          showExportOnlyPersonalDataAlert = true
        }
      case .disabled:
        showExportDisabledAlert = true
      case .complete:
        accessControl.requestAccess(for: .export) { granted in
          guard granted else {
            return
          }

          export()
        }
      }
    } label: {
      Text(title)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .textStyle(.body.standard.regular)
    }
    .sheet(isPresented: $showExportOnlyPersonalDataAlert) {
      ExportLimitedSheet {
        export()
      }
    }
    .alert(
      L10n.Localizable.dpsExportRestrictedAlertTitle,
      isPresented: $showExportDisabledAlert,
      actions: {
        Button(L10n.Localizable.dpsExportRestrictedAction, role: .cancel) {}
      },
      message: {
        Text(L10n.Localizable.dpsExportRestrictedAlertMessage)
      })
  }
}
