import CoreFeature
import CoreLocalization
import CoreSharing
import DashTypes
import DesignSystem
import SwiftUI

public struct SharingPermissionActionSheet: View {

  public enum Action {
    case changePermission(SharingPermission)
    case revoke
    case cancel
  }

  private enum SelectedButton {
    case admin
    case limited
    case revoke

    var permission: SharingPermission? {
      switch self {
      case .admin:
        return .admin
      case .limited:
        return .limited
      case .revoke:
        return nil
      }
    }
  }

  @FeatureState(.sharingCollectionPermissionEdition)
  var permissionEditionEnabled: Bool

  let memberIdentifier: String
  let permission: SharingPermission
  let status: SharingMemberStatus
  let currentAction: Action?
  let action: (Action) -> Void

  public init(
    memberIdentifier: String,
    permission: SharingPermission,
    status: SharingMemberStatus,
    currentAction: Action?,
    action: @escaping (Action) -> Void
  ) {
    self.memberIdentifier = memberIdentifier
    self.permission = permission
    self.status = status
    self.currentAction = currentAction
    self.action = action
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        HStack {
          Text(L10n.Core.sharingPermissionsTitle)
            .textStyle(.title.section.medium)
            .foregroundStyle(Color.ds.text.neutral.catchy)
            .frame(maxWidth: .infinity, alignment: .leading)

          Button {
            action(.cancel)
          } label: {
            Image.ds.action.close.outlined
              .resizable()
              .frame(width: 16, height: 16)
              .foregroundStyle(Color.ds.border.neutral.standard.active)
              .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                  .foregroundStyle(Color.ds.container.expressive.neutral.quiet.idle)
                  .frame(width: 32, height: 32)
              )
          }
        }

        Text(L10n.Core.sharingPermissionsSubtitle)
          .textStyle(.body.reduced.regular)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .frame(maxWidth: .infinity, alignment: .leading)

        permissionButton(for: .limited)
        permissionButton(for: .admin)
        revokeButton

        Spacer()
      }
      .padding(16)
    }
    .background(Color.ds.container.agnostic.neutral.standard)
  }

  private var selectedButton: SelectedButton {
    if let currentAction {
      switch currentAction {
      case .changePermission(let permission) where permission == .admin:
        return .admin
      case .changePermission(let permission) where permission == .limited:
        return .limited
      case .revoke:
        return .revoke
      default:
        break
      }
    }

    switch permission {
    case .admin:
      return .admin
    case .limited:
      return .limited
    }
  }

  func permissionButton(for permission: SharingPermission) -> some View {
    SharingPermissionActionSheetButton(
      title: permissionButtonTitle(for: permission),
      subtitle: permissionButtonSubtitle(for: permission),
      selected: permission == selectedButton.permission,
      disabled: !permissionEditionEnabled,
      destructive: false,
      action: { action(.changePermission(permission)) }
    )
  }

  func permissionButtonTitle(for permission: SharingPermission) -> String {
    switch permission {
    case .limited:
      return L10n.Core.KWVaultItem.Collections.Sharing.Roles.Editor.title
    case .admin:
      return L10n.Core.KWVaultItem.Collections.Sharing.Roles.Manager.title
    }
  }

  func permissionButtonSubtitle(for permission: SharingPermission) -> String {
    switch permission {
    case .limited:
      return L10n.Core.sharingPermissionsEditorDescription
    case .admin:
      return L10n.Core.sharingPermissionsManagerDescription
    }
  }

  var revokeButton: some View {
    SharingPermissionActionSheetButton(
      title: revokeButtonTitle,
      subtitle: revokeButtonSubtitle,
      selected: selectedButton == .revoke,
      disabled: false,
      destructive: true,
      action: { action(.revoke) }
    )
  }

  var revokeButtonTitle: String {
    switch status {
    case .pending:
      return L10n.Core.kwRevokeInvite
    default:
      return L10n.Core.kwRevoke
    }
  }

  var revokeButtonSubtitle: String {
    switch status {
    case .pending:
      return L10n.Core.sharingPermissionsRevokeInviteDescription
    default:
      return L10n.Core.sharingPermissionsRevokeDescription
    }
  }
}

private struct SharingPermissionActionSheetButton: View {
  let title: String
  let subtitle: String
  let selected: Bool
  let disabled: Bool
  let destructive: Bool
  let action: () -> Void

  fileprivate var body: some View {
    VStack {
      Button {
        action()
      } label: {
        HStack {
          Image.ds.checkmark.outlined
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(
              titleColor.opacity(selected ? 1 : 0)
            )

          Text(title)
            .textStyle(.body.standard.regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(titleColor)
        }
      }
      .padding(12)
      .background(Color.ds.container.agnostic.neutral.supershy)
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

      Text(subtitle)
        .textStyle(.body.helper.regular)
        .foregroundStyle(subtitleColor)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .disabled(disabled)
  }

  private var titleColor: Color {
    if disabled {
      return .ds.text.oddity.disabled
    } else if destructive {
      return .ds.text.warning.standard
    } else {
      return .ds.text.neutral.standard
    }
  }

  private var subtitleColor: Color {
    disabled ? .ds.text.oddity.disabled : .ds.text.neutral.standard
  }
}

struct SharingPermissionActionView_Previews: PreviewProvider {
  static var previews: some View {
    Text("Sheet preview")
      .textStyle(.title.section.large)
      .bottomSheet(isPresented: .constant(true)) {
        SharingPermissionActionSheet(
          memberIdentifier: "",
          permission: .admin,
          status: .accepted,
          currentAction: nil
        ) { _ in }
      }
  }
}
