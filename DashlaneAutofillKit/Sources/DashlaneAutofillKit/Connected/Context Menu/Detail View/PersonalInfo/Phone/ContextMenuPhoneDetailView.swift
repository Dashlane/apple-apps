import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuPhoneDetailView: View {

  @StateObject var model: ContextMenuPhoneDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuPhoneDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !model.item.number.isEmpty {
          phone
        }
        if model.item.country != nil {
          country
        }
      }
    }
  }

  private var phone: some View {
    DisplayField(CoreL10n.KWPhoneIOS.number, text: model.item.number)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.number)
      }
  }

  private var country: some View {
    DisplayField(CoreL10n.KWPhoneIOS.localeFormat, text: model.item.country?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.country?.name ?? "")
      }
  }

}

#Preview {
  ContextMenuPhoneDetailView(model: .mock())
}
