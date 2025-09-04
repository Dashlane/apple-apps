import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuSecretDetailView: View {

  @StateObject var model: ContextMenuSecretDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuSecretDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !model.item.content.isEmpty {
          secret
        }
      }
    }
  }

  private var secret: some View {
    DisplayField(CoreL10n.secretContent, text: model.item.content)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.content)
      }
  }
}

#Preview {
  ContextMenuSecretDetailView(model: .mock())
}
