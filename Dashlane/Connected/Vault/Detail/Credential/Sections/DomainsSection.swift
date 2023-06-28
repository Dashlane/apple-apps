import SwiftUI
import UIDelight
import DesignSystem
import UIComponents
import VaultKit
import CoreLocalization

struct DomainsSection: View {

    @ObservedObject
    var model: DomainsSectionModel

    @Binding
    var showLinkedDomains: Bool

    @Binding
    var showAddedDomainsList: Bool

    var body: some View {
        if model.item.url != nil || model.mode.isEditing {
            Section(header: Text(CoreLocalization.L10n.Core.KWAuthentifiantIOS.urlStringForUI.uppercased())) {
                                if model.mode == .viewing {
                                        model.item.url.map {
                        URLLinkDetailField(personalDataURL: $0,
                                           onOpenUrl: {
                            self.model.logOpenUrl()
                        })
                    }
                } else {
                    TextField(CoreLocalization.L10n.Core.KWAuthentifiantIOS.url, text: $model.item.editableURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .fiberAccessibilityElement(children: .combine)
                        .fiberAccessibilityLabel(Text("\(CoreLocalization.L10n.Core.KWAuthentifiantIOS.url): \(model.item.editableURL)"))
                        .limitedRights(item: model.item)
                }

                                if model.linkedDomainsCount > 0 && !model.item.subdomainOnly {
                    LinkDetailField(title: L10n.Localizable.linkedDomainsDetailViewMessage(String(model.linkedDomainsCount))) {
                        self.showLinkedDomains = true
                    }
                }

                                if model.mode.isEditing && model.item.url != nil && model.canAddDomain {
                    Button(action: {
                        self.showAddedDomainsList = true
                    }, label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.ds.text.positive.standard)
                            Text(L10n.Localizable.credentialDetailViewAddDomain)
                                .padding(.horizontal, 5)
                                .foregroundColor(.ds.text.brand.standard)
                        }
                    })
                }
            }
        }
    }
}
