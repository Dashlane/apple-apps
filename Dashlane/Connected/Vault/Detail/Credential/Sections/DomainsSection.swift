import CoreLocalization
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIDelight
import VaultKit

struct DomainsSection: View {
  @StateObject var model: DomainsSectionModel

  @Binding var showLinkedDomains: Bool
  @Binding var showAddedDomainsList: Bool

  init(
    model: @escaping @autoclosure () -> DomainsSectionModel,
    showLinkedDomains: Binding<Bool>,
    showAddedDomainsList: Binding<Bool>
  ) {
    self._model = .init(wrappedValue: model())
    self._showLinkedDomains = showLinkedDomains
    self._showAddedDomainsList = showAddedDomainsList
  }

  var body: some View {
    if model.item.url != nil || model.mode.isEditing {
      Section(header: Text(CoreL10n.KWAuthentifiantIOS.urlStringForUI.uppercased())) {
        if model.mode == .viewing {
          model.item.url.map {
            URLLinkDetailField(
              personalDataURL: $0,
              onOpenURL: {
                self.model.logOpenUrl()
              }
            )
          }
        } else {
          DS.TextField(CoreL10n.KWAuthentifiantIOS.url, text: $model.item.editableURL)
            .fieldLabelHiddenOnFocus()
            .textFieldColorHighlightingMode(.url)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .lineLimit(1)
            .fiberAccessibilityElement(children: .combine)
            .fiberAccessibilityLabel(
              Text("\(CoreL10n.KWAuthentifiantIOS.url): \(model.item.editableURL)")
            )
            .limitedRights(item: model.item, isFrozen: model.service.isFrozen)
        }

        if model.linkedDomainsCount > 0 && !model.item.subdomainOnly {
          NativeNavigationPushRow(
            title: L10n.Localizable.linkedDomainsDetailViewMessage(String(model.linkedDomainsCount))
          ) {
            self.showLinkedDomains = true
          }
        }

        if model.mode.isEditing && model.item.url != nil && model.canAddDomain {
          Button(
            action: {
              self.showAddedDomainsList = true
            },
            label: {
              HStack {
                Image(systemName: "plus.circle.fill")
                  .foregroundStyle(Color.ds.text.positive.standard)
                Text(L10n.Localizable.credentialDetailViewAddDomain)
                  .padding(.horizontal, 5)
                  .foregroundStyle(Color.ds.text.brand.standard)
              }
            })
        }
      }
    }
  }
}
