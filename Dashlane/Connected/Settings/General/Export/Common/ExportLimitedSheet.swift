import DesignSystem
import SwiftUI

struct ExportLimitedSheet: View {
  @Environment(\.dismiss) private var dismiss

  let completion: () -> Void

  var body: some View {
    VStack(spacing: 40) {
      VStack(spacing: 8) {
        Text(L10n.Localizable.dpsExportOnlyYourPersonalData)
          .textStyle(.title.section.medium)
          .lineLimit(nil)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        Text(L10n.Localizable.dpsYourCompanyPolicyPreventsExporting)
          .textStyle(.body.standard.regular)
          .lineLimit(nil)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .frame(maxWidth: .infinity, alignment: .leading)
        Infobox(L10n.Localizable.dpsBeforeContinuing)
          .padding(.top, 8)
      }
      .fixedSize(horizontal: false, vertical: true)
      VStack(spacing: 8) {
        Button(L10n.Localizable.kwCmContinue) {
          dismiss()
          completion()
        }
        Button(L10n.Localizable.dpsCancel) {
          dismiss()
        }
        .style(intensity: .quiet)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 24)
    .presentationDetents([.medium])
  }
}

#Preview {
  ExportLimitedSheet {
    print("Export")
  }
}
