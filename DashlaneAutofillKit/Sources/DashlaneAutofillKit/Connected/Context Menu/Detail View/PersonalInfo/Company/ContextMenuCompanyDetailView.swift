import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuCompanyDetailView: View {

  @StateObject var model: ContextMenuCompanyDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuCompanyDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !model.item.name.isEmpty {
          companyName
        }

        if !model.item.jobTitle.isEmpty {
          jobTitle
        }
      }
    }
  }

  private var companyName: some View {
    DisplayField(CoreL10n.KWCompanyIOS.name, text: model.item.name)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.name)
      }
  }

  private var jobTitle: some View {
    DisplayField(CoreL10n.KWCompanyIOS.jobTitle, text: model.item.jobTitle)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.jobTitle)
      }
  }
}

#Preview {
  ContextMenuCompanyDetailView(model: .mock())
}
