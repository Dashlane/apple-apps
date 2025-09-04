import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuBankAccountDetailView: View {

  @StateObject var model: ContextMenuBankAccountDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuBankAccountDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if model.selectedCountry != nil {
          country
        }
        if !model.item.owner.isEmpty {
          accountHolder
        }
        if !model.item.bic.isEmpty {
          bicNumber
        }
        if !model.item.iban.isEmpty {
          ibanNumber
        }
        if let selectedBank = model.selectedBank, !selectedBank.name.isEmpty {
          bank
        }
      }
    }
  }

  private var country: some View {
    DisplayField(CoreL10n.KWBankStatementIOS.localeFormat, text: model.selectedCountry?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.selectedCountry?.name ?? "")
      }
  }

  private var accountHolder: some View {
    DisplayField(CoreL10n.KWBankStatementIOS.bankAccountOwner, text: model.item.owner)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.owner)
      }
  }

  private var bicNumber: some View {
    DS.ObfuscatedDisplayField(
      CoreL10n.KWBankStatementIOS.bicFieldTitle(for: model.item.bicVariant), value: model.item.bic,
      format: .accountIdentifier(.bic), actions: {}
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.bic)
    }
  }

  private var ibanNumber: some View {
    DS.ObfuscatedDisplayField(
      CoreL10n.KWBankStatementIOS.ibanFieldTitle(for: model.item.ibanVariant),
      value: model.item.iban, format: .accountIdentifier(.iban), actions: {}
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.iban)
    }
  }

  private var bank: some View {
    DisplayField(CoreL10n.KWBankStatementIOS.bankAccountBank, text: model.selectedBank?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.selectedBank?.name ?? "")
      }
  }
}

#Preview {
  ContextMenuBankAccountDetailView(model: .mock())
}
