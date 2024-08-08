import CoreFeature
import CoreLocalization
import CorePasswords
import CorePersonalData
import DashTypes
import DesignSystem
import IconLibrary
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

public struct SecretDetailView: View, DismissibleDetailView {
  @StateObject var model: SecretDetailViewModel

  @Environment(\.navigator) public var navigator
  @Environment(\.dismiss) public var dismissAction
  @Environment(\.detailContainerViewSpecificDismiss) public var dismissView

  public init(model: @escaping @autoclosure () -> SecretDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    DetailContainerView(service: model.service) {
      mainSection

      SharingDetailSection(
        model: model.sharingDetailSectionModelFactory.make(item: model.item),
        ctaLabel: CoreLocalization.L10n.Core.Secrets.Sharing.ctaLabel
      )
    }
    .makeShortcuts(model: model)
    .detailContainerViewSpecificSave(.init(model.save))
  }

  var mainSection: some View {
    SecretMainSection(model: model.makeSecretMainSectionViewModel())
  }
}

extension View {
  fileprivate func makeShortcuts(model: SecretDetailViewModel) -> some View {
    self.mainMenuShortcut(
      .copyPrimary(title: CoreLocalization.L10n.Core.secretCopyActionCTA),
      enabled: !model.mode.isEditing && !model.item.content.isEmpty,
      action: { model.copy(model.item.content, fieldType: .note) }
    )
  }
}

struct SecretDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      SecretDetailView(
        model: MockVaultConnectedContainer().makeSecretDetailViewModel(
          item: PersonalDataMock.Secrets.rsaKeyExample,
          mode: .viewing
        )
      )

      SecretDetailView(
        model: MockVaultConnectedContainer().makeSecretDetailViewModel(
          item: PersonalDataMock.Secrets.rsaKeyExample,
          mode: .updating
        )
      )

      SecretDetailView(
        model: MockVaultConnectedContainer().makeSecretDetailViewModel(
          item: PersonalDataMock.Secrets.rsaKeyExample,
          mode: .adding(prefilled: false)
        )
      )
    }
  }
}
