import SwiftUI
import CoreFeature

@MainActor
struct SharingDetailSection: View {
    let model: SharingDetailSectionModel

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.navigator)
    var navigator

    var body: some View {
        activeSharingSection

        if !detailMode.isEditing && !model.item.hasAttachments && model.item.metadata.isShareable {
            Section {
                shareButton
            }
        }
    }

    @ViewBuilder
    var shareButton: some View {
        ShareButton(model: model.makeShareButtonViewModel()) {
            Text(L10n.Localizable.kwSharePassword)
        }
        .buttonStyle(DetailRowButtonStyle())
    }

    @ViewBuilder
    var activeSharingSection: some View {
        if model.item.isShared {
            Section(header: Text(L10n.Localizable.contactsTitle.uppercased())) {
                SharingMembersDetailLink(model: model.makeSharingMembersDetailLinkModel())
            }
        }
    }
}
