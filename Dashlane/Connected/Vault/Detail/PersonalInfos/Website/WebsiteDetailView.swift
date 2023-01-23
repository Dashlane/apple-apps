import Foundation
import SwiftUI
import CorePersonalData
import UIDelight

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
                    TextDetailField(title: L10n.Localizable.KWPersonalWebsiteIOS.name, text: $model.item.name)
                        .textInputAutocapitalization(.words)
                }
                TextDetailField(title: L10n.Localizable.KWPersonalWebsiteIOS.website,
                                text: $model.item.website)
                    .openAction { self.model.logger.logVisitWebsite(item: self.model.item) }
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
