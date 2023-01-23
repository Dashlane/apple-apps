import SwiftUI
import CorePersonalData
import CoreUserTracking

struct FiscalInformationMenu: View {
    var fiscalInformation: FiscalInformation
    let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

    var body: some View {
        if !fiscalInformation.fiscalNumber.isEmpty {
            CopyMenuButton(L10n.Localizable.kwCopyFiscalNumberButton) {
                copyAction(.fiscalNumber, fiscalInformation.fiscalNumber)
            }
        }

        if !fiscalInformation.teledeclarationNumber.isEmpty {
            CopyMenuButton(L10n.Localizable.copyTeledeclarantNumber) {
                copyAction(.teledeclarantNumber, fiscalInformation.teledeclarationNumber)
            }
        }
    }
}
