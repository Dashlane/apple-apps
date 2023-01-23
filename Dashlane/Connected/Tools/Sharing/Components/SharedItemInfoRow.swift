import Foundation
import SwiftUI
import DesignSystem
import VaultKit
import CoreSharing
import DashTypes
import SwiftTreats
import UIDelight

struct SharedItemInfoRow<Recipient: SharingGroupMember, Action: View>: View {
    let model: SharedItemInfoRowViewModel<Recipient>

    @ViewBuilder
    let actions: () -> Action

    @Environment(\.showVaultItem)
    var showVaultItem

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            let isAdmin = model.item.vaultItem.metadata.sharingPermission == .admin
            mainBody
                .contextMenu {
                    if isAdmin {
                        actions()
                    }
                }
            if isAdmin {
                Menu(content: actions) {
                    SharingEditLabel(isInProgress: model.inProgress)
                }.disabled(model.inProgress)
            }
        }.animation(.easeInOut, value: model.inProgress)
    }

    var mainBody: some View {
        HStack(alignment: .center, spacing: 16) {
            VaultItemIconView(isListStyle: true, model: model.vaultIconViewModelFactory.make(item: model.item.vaultItem))
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(model.item.vaultItem.localizedTitle)
                        .lineLimit(1)
                        .font(.body)
                        .foregroundColor(.ds.text.neutral.catchy)
                    if let space = model.userSpace {
                        UserSpaceIcon(space: space, size: .small).equatable()
                    }
                }

                Text(model.item.vaultItem.localizedSubtitle)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.ds.text.neutral.quiet)
                Text(model.item.localizedStatus)
                    .font(.caption)
                    .foregroundColor(.ds.text.neutral.quiet)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapWithFeedback {
            showVaultItem(model.item.vaultItem)
        }
    }
}
