import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuFiscalInformationDetailView: View {

  @StateObject var model: ContextMenuFiscalInformationDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuFiscalInformationDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if model.selectedCountry != nil {
          country
        }
        if !model.item.fiscalNumber.isEmpty {
          fiscalNumber
        }
        if model.item.mode == .franceAndBelgium && !model.item.teledeclarationNumber.isEmpty {
          teledeclarantNumber
        }
      }
    }
  }

  private var country: some View {
    DisplayField(
      CoreL10n.KWFiscalStatementIOS.localeFormat, text: model.selectedCountry?.name ?? ""
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.selectedCountry?.name ?? "")
    }
  }

  private var fiscalNumber: some View {
    DisplayField(CoreL10n.KWFiscalStatementIOS.fiscalNumber, text: model.item.fiscalNumber)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.fiscalNumber)
      }
  }

  private var teledeclarantNumber: some View {
    DisplayField(
      CoreL10n.KWFiscalStatementIOS.teledeclarantNumber, text: model.item.teledeclarationNumber
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.teledeclarationNumber)
    }
  }
}

#Preview {
  ContextMenuFiscalInformationDetailView(model: .mock())
}
