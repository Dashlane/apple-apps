import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuWebsiteDetailView: View {

  @StateObject var model: ContextMenuWebsiteDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuWebsiteDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !model.item.name.isEmpty {
          name
        }

        if !model.item.website.isEmpty {
          website
        }
      }
    }
  }

  private var name: some View {
    DisplayField(CoreL10n.KWPersonalWebsiteIOS.name, text: model.item.name)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.name)
      }
  }

  private var website: some View {
    DisplayField(CoreL10n.KWPersonalWebsiteIOS.website, text: model.item.website)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.website)
      }
  }
}

#Preview {
  ContextMenuWebsiteDetailView(model: .mock())
}
