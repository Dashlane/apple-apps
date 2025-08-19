import CoreLocalization
import CoreSharing
import CoreTypes
import DesignSystem
import Foundation
import IconLibrary
import SwiftUI

struct SharingToolRecipientRow<Icon: View>: View {
  private enum Subtitle: View {
    case status(SharingMemberStatus)
    case other(String?)

    var body: some View {
      switch self {
      case .status(let status) where status == .pending:
        HStack(spacing: 2) {
          Image.ds.time.outlined
            .resizable()
            .frame(width: 12, height: 12)

          Text(CoreL10n.kwSharingInvitePending)
            .lineLimit(1)
            .textStyle(.body.helper.regular)
        }
        .foregroundStyle(Color.ds.text.warning.quiet)
      case .other(let subtitle):
        if let subtitle {
          Text(subtitle)
            .textStyle(.body.helper.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
      default:
        EmptyView()
      }
    }
  }

  private let title: String
  private let subtitle: Subtitle
  private let icon: Icon

  init(title: String, status: SharingMemberStatus, @ViewBuilder icon: () -> Icon) {
    self.title = title
    self.subtitle = .status(status)
    self.icon = icon()
  }

  init(
    title: String, subtitle: String?, permission: SharingPermission? = nil,
    @ViewBuilder icon: () -> Icon
  ) {
    self.title = title
    if let permission {
      self.subtitle = .other(L10n.Localizable.subtitle(for: permission))
    } else {
      self.subtitle = .other(subtitle)
    }
    self.icon = icon()
  }

  init(
    title: String, itemsCount: Int, permission: SharingPermission? = nil,
    @ViewBuilder icon: () -> Icon
  ) {
    self.title = title
    self.subtitle = .other(
      L10n.Localizable.rowItemsSubtitle(forCount: itemsCount, permission: permission))
    self.icon = icon()
  }

  init(
    title: String, usersCount: Int, permission: SharingPermission? = nil,
    @ViewBuilder icon: () -> Icon
  ) {
    self.title = title
    self.subtitle = .other(
      L10n.Localizable.rowUsersSubtitle(forCount: usersCount, permission: permission))
    self.icon = icon()
  }

  var body: some View {
    HStack(spacing: 16) {
      icon

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .textStyle(.body.standard.regular)
          .lineLimit(1)

        subtitle
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .contentShape(Rectangle())
  }
}

extension L10n.Localizable {
  fileprivate static func rowItemsSubtitle(forCount count: Int, permission: SharingPermission?)
    -> String
  {
    switch permission {
    case .none:
      return rowItemsSubtitle(forCount: count)
    case .some(let permission):
      return "\(rowItemsSubtitle(forCount: count)) • \(subtitle(for: permission))"
    }
  }

  private static func rowItemsSubtitle(forCount count: Int) -> String {
    let subtitle = count > 1 ? L10n.Localizable.kwItemsShared : L10n.Localizable.kwItemShared
    let finalSubtitle = "\(count) \(subtitle)"
    return finalSubtitle
  }

  fileprivate static func rowUsersSubtitle(forCount count: Int, permission: SharingPermission?)
    -> String
  {
    switch permission {
    case .none:
      return rowUsersSubtitle(forCount: count)
    case .some(let permission):
      return "\(rowUsersSubtitle(forCount: count)) • \(subtitle(for: permission))"
    }
  }

  private static func rowUsersSubtitle(forCount count: Int) -> String {
    return count > 1
      ? L10n.Localizable.kwSharingUsersPlural(count)
      : L10n.Localizable.kwSharingUsersSingular(count)
  }

  fileprivate static func subtitle(for permission: SharingPermission) -> String {
    switch permission {
    case .admin:
      return CoreL10n.KWVaultItem.Collections.Sharing.Roles.Manager.title
    case .limited:
      return CoreL10n.KWVaultItem.Collections.Sharing.Roles.Editor.title
    }
  }
}

#Preview {
  List {
    SharingToolRecipientRow(title: "Preview", status: .accepted) {
      Thumbnail.User.single(nil)
    }
  }
}
