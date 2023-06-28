import Foundation
import SwiftUI
import CorePersonalData
import UIDelight
import VaultKit
import CoreLocalization

struct WebsiteDetailView: View {
    @ObservedObject
    var model: WebsiteDetailViewModel

    init(model: WebsiteDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                if model.mode.isEditing {
                    TextDetailField(title: CoreLocalization.L10n.Core.KWPersonalWebsiteIOS.name, text: $model.item.name)
                        .textInputAutocapitalization(.words)
                }
                TextDetailField(title: CoreLocalization.L10n.Core.KWPersonalWebsiteIOS.website,
                                text: $model.item.website)
                    .openAction()
                    .keyboardType(.URL)
            }
        }
    }
}

struct WebsiteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            WebsiteDetailView(model: MockVaultConnectedContainer().makeWebsiteDetailViewModel(item: PersonalDataMock.PersonalWebsites.blog, mode: .viewing))
            WebsiteDetailView(model: MockVaultConnectedContainer().makeWebsiteDetailViewModel(item: PersonalDataMock.PersonalWebsites.blog, mode: .updating))
        }
    }
}
