import CorePersonalData
import CoreSharing
import DashTypes
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit

struct SharedItemInfoRow<Recipient: SharingGroupMember, Action: View>: View {
  let model: SharedItemInfoRowViewModel<Recipient>
  let select: () -> Void
  @ViewBuilder
  let menuActions: () -> Action

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      let isAdmin = model.item.vaultItem.metadata.sharingPermission == .admin
      mainBody
        .onTapWithFeedback {
          select()
        }
        .contextMenu {
          if isAdmin {
            menuActions()
          }
        }
      if isAdmin {
        Menu(content: menuActions) {
          SharingEditLabel(isInProgress: model.inProgress)
        }.disabled(model.inProgress)
      }
    }.animation(.easeInOut, value: model.inProgress)
  }

  var mainBody: some View {
    HStack(alignment: .center, spacing: 16) {
      VaultItemIconView(isListStyle: true, model: model.makeIconViewModel())

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
    .padding(.trailing, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview("Admin") {
  List {
    SharedItemInfoRow(
      model: SharedItemInfoRowViewModel<UserGroupMember<UserGroup>>.mock(
        isAdmin: true,
        inProgress: false
      )
    ) {

    } menuActions: {
      FieldAction.Menu(
        L10n.Localizable.kwSharingItemEditAccess,
        image: .ds.action.edit.outlined
      ) {
        FieldAction.CopyContent {}
      }
    }
  }
  .listAppearance(.insetGrouped)
}
