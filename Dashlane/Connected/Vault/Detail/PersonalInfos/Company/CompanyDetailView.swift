import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI
import UIDelight
import VaultKit

struct CompanyDetailView: View {
  @StateObject var model: CompanyDetailViewModel

  init(model: @escaping @autoclosure () -> CompanyDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWCompanyIOS.name, text: $model.item.name
          )
          .textInputAutocapitalization(.words)
        }
        TextDetailField(
          title: CoreLocalization.L10n.Core.KWCompanyIOS.jobTitle, text: $model.item.jobTitle
        )
        .textInputAutocapitalization(.words)
      }
    }
  }
}

struct CompanyDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      CompanyDetailView(
        model: MockVaultConnectedContainer().makeCompanyDetailViewModel(
          item: PersonalDataMock.Companies.dashlane, mode: .viewing))
      CompanyDetailView(
        model: MockVaultConnectedContainer().makeCompanyDetailViewModel(
          item: PersonalDataMock.Companies.dashlane, mode: .updating))
    }
  }
}
