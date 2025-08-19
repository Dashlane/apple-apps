import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuEmailDetailView: View {

  @StateObject var model: ContextMenuEmailDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuEmailDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !model.item.value.isEmpty {
          email
        }
      }
    }
  }

  private var email: some View {
    DisplayField(CoreL10n.KWEmailIOS.email, text: model.item.value)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.value)
      }
  }
}

#Preview {
  ContextMenuEmailDetailView(model: .mock())
}
