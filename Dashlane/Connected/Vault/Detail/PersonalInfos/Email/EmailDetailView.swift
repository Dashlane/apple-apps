import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI
import UIDelight
import VaultKit

struct EmailDetailView: View {
  @StateObject var model: EmailDetailViewModel

  init(model: @escaping @autoclosure () -> EmailDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWEmailIOS.emailName, text: $model.item.name
          )
          .textInputAutocapitalization(.words)
        }

        TextDetailField(
          title: CoreLocalization.L10n.Core.KWEmailIOS.email,
          text: $model.item.value,
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy)])
        .keyboardType(.emailAddress)
        .fiberFieldType(.email)

        if model.hasTypeField {
          PickerDetailField(
            title: CoreLocalization.L10n.Core.KWEmailIOS.type,
            selection: $model.item.type,
            elements: Email.EmailType.allCases,
            content: { item in
              Text((item ?? Email.EmailType.defaultValue).localizedString)
            })
        }
      }
    }
  }
}

struct EmailDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      EmailDetailView(
        model: MockVaultConnectedContainer().makeEmailDetailViewModel(
          item: PersonalDataMock.Emails.personal, mode: .viewing))
      EmailDetailView(
        model: MockVaultConnectedContainer().makeEmailDetailViewModel(
          item: PersonalDataMock.Emails.personal, mode: .updating))
    }
  }
}
