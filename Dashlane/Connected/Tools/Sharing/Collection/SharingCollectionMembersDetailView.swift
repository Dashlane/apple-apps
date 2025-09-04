import CoreFeature
import CoreLocalization
import CoreSharing
import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import VaultKit

public struct SharingCollectionMembersDetailView: View {

  public enum Action {
    case done(accessChanged: Bool)
  }

  private struct RevokeConfirmationDialog {
    let userOrUserGroupName: String
    let action: () -> Void
  }

  private struct ActionSheetInfo: Identifiable {
    let id: String
    let permission: SharingPermission
    let status: SharingMemberStatus
    let currentAction: SharingPermissionActionSheet.Action?
  }

  @StateObject
  var model: SharingCollectionMembersDetailViewModel

  @FeatureState(.sharingCollectionPermissionDisplay)
  private var permissionsDisplayEnabled

  @State
  private var showRevokeAlert: Bool = false

  @State
  private var revokeConfirmationDialog: RevokeConfirmationDialog?

  @State
  private var actionSheetInfo: ActionSheetInfo?

  private let action: (Action) -> Void

  public init(
    model: @autoclosure @escaping () -> SharingCollectionMembersDetailViewModel,
    action: @escaping (Action) -> Void = { _ in }
  ) {
    self._model = .init(wrappedValue: model())
    self.action = action
  }

  public var body: some View {
    VStack(spacing: 0) {
      list
      updateButton
    }
    .toolbar { toolbarContent }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(CoreL10n.kwSharedAccess)
    .alert(item: $model.alertMessage) { message in
      Alert(title: Text(message))
    }
    .searchable(
      text: $model.search,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: Text(CoreL10n.kwSharedAccessSearchPlaceholder)
    )
    .confirmationDialog(
      L10n.Localizable.kwRevokeAlertTitle,
      isPresented: $showRevokeAlert,
      titleVisibility: .visible,
      presenting: revokeConfirmationDialog
    ) { revokeConfirmationDialog in
      Button(L10n.Localizable.kwRevokeAccess, role: .destructive) {
        revokeConfirmationDialog.action()
      }
    } message: { revokeConfirmationDialog in
      Text(CoreL10n.kwRevokeCollectionMessage(revokeConfirmationDialog.userOrUserGroupName))
    }
    .sheet(item: $actionSheetInfo) { actionSheetInfo in
      SharingPermissionActionSheet(
        memberIdentifier: actionSheetInfo.id,
        permission: actionSheetInfo.permission,
        status: actionSheetInfo.status,
        currentAction: actionSheetInfo.currentAction
      ) { action in
        switch action {
        case .changePermission(let newPermission):
          model.actionToProcess.append(
            (memberId: actionSheetInfo.id, action: .changePermission(newPermission)))
        case .revoke:
          model.actionToProcess.append((memberId: actionSheetInfo.id, action: .revoke))
        default:
          break
        }
        self.actionSheetInfo = nil
      }
    }
    .background(Color.ds.background.alternate)
  }

  var list: some View {
    List {
      userGroupsList
      usersList
    }
    .listStyle(.ds.insetGrouped)
    .headerProminence(.increased)
  }

  @ViewBuilder
  var updateButton: some View {
    if !model.actionToProcess.isEmpty {
      VStack(spacing: 16) {
        Divider()
          .padding(.horizontal, 16)

        Button(CoreL10n.update) {
          Task {
            await model.update()
            action(.done(accessChanged: true))
          }
        }
        .buttonStyle(.designSystem(.titleOnly))
        .buttonDisplayProgressIndicator(model.isLoading)
      }
      .padding(.horizontal, 16)
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(
        permissionsDisplayEnabled ? CoreL10n.cancel : CoreL10n.kwButtonClose
      ) {
        action(.done(accessChanged: model.accessChanged))
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      if model.accessChanged {
        Button(CoreL10n.kwDoneButton) {
          action(.done(accessChanged: model.accessChanged))
        }
      }
    }
  }

  @ViewBuilder
  var userGroupsList: some View {
    if let userGroupMembers = model.members?.userGroupMembers, !userGroupMembers.isEmpty {
      ForEach(userGroupMembers) { userGroup in
        HStack {
          SharingToolRecipientRow(title: userGroup.name, status: userGroup.status) {
            Thumbnail.User.single(nil)
          }
          button(for: userGroup)
            .disabled(model.groupActionInProgressIds.contains(userGroup.id))
        }
      }
    }
  }

  @ViewBuilder
  var usersList: some View {
    if let users = model.members?.users, !users.isEmpty {
      ForEach(users) { user in
        if user.id != model.currentUserId {
          HStack {
            SharingToolRecipientRow(title: user.id, status: user.status) {
              GravatarIconView(model: model.gravatarViewModelFactory.make(email: user.id))
            }

            button(for: user)
              .disabled(model.userActionInProgressIds.contains(user.id))
          }
        }
      }
    }
  }

  @ViewBuilder
  func button(for userGroup: UserGroupMember<SharingCollection>) -> some View {
    if !permissionsDisplayEnabled {
      button(for: userGroup.status, with: userGroup.name) {
        model.revoke(userGroup)
      }
    } else {
      button(for: userGroup.id.rawValue, status: userGroup.status, permission: userGroup.permission)
    }
  }

  @ViewBuilder
  func button(for user: User<SharingCollection>) -> some View {
    if !permissionsDisplayEnabled {
      button(for: user.status, with: user.id) {
        model.revoke(user)
      }
    } else {
      button(for: user.id, status: user.status, permission: user.permission)
    }
  }

  func button(
    for status: SharingMemberStatus,
    with userOrUserGroupName: String,
    action: @escaping () -> Void
  ) -> some View {
    let title: String
    let color: Color
    switch status {
    case .pending:
      title = CoreL10n.kwRevokeInvite
      color = .ds.text.brand.standard
    default:
      title = CoreL10n.kwRevoke
      color = .ds.text.danger.standard
    }

    return Button(
      title,
      action: {
        revokeConfirmationDialog = .init(userOrUserGroupName: userOrUserGroupName, action: action)
        showRevokeAlert = true
      }
    )
    .foregroundStyle(color)
  }

  func button(
    for identifier: String,
    status: SharingMemberStatus,
    permission: SharingPermission
  ) -> some View {
    let buttonTitle: String
    let buttonColor: Color
    let currentAction: SharingPermissionActionSheet.Action?

    if let actionToProcess = model.actionToProcess.first(where: { $0.memberId == identifier })?
      .action
    {
      switch actionToProcess {
      case .revoke:
        buttonTitle = self.buttonTitle(for: status)
        buttonColor = .ds.text.danger.standard
        currentAction = .revoke
      case .changePermission(let permission):
        buttonTitle = self.buttonTitle(for: permission)
        buttonColor = .ds.text.brand.standard
        currentAction = .changePermission(permission)
      }
    } else {
      buttonTitle = self.buttonTitle(for: permission)
      buttonColor = .ds.text.brand.standard
      currentAction = nil
    }

    return Button {
      actionSheetInfo = .init(
        id: identifier,
        permission: permission,
        status: status,
        currentAction: currentAction
      )
    } label: {
      HStack {
        Text(buttonTitle)
          .textStyle(.body.standard.regular)

        VStack(spacing: -3) {
          Image.ds.caretUp.outlined
            .resizable()
            .frame(width: 12, height: 12)

          Image.ds.caretDown.outlined
            .resizable()
            .frame(width: 12, height: 12)
        }
      }
    }
    .foregroundStyle(buttonColor)
  }
}

extension SharingCollectionMembersDetailView {
  fileprivate func buttonTitle(for permission: SharingPermission) -> String {
    switch permission {
    case .admin:
      return CoreL10n.KWVaultItem.Collections.Sharing.Roles.Manager.title
    case .limited:
      return CoreL10n.KWVaultItem.Collections.Sharing.Roles.Editor.title
    }
  }

  fileprivate func buttonTitle(for status: SharingMemberStatus) -> String {
    switch status {
    case .pending:
      return CoreL10n.kwRevokeInvite
    default:
      return CoreL10n.kwRevoke
    }
  }
}
