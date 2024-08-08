import CoreLocalization
import CorePersonalData
import DashTypes
import Foundation
import IconLibrary
import SwiftUI
import VaultKit

public struct SharingNotificationInfo: Hashable {
  var settingsPrefix: String {
    "sharing-nrrequest-\(id.rawValue)"
  }

  public enum SharingNotificationKind {
    case item(VaultItem)
    case userGroup
    case collection(String)

    var vaultItem: VaultItem? {
      switch self {
      case .item(let item):
        return item
      case .userGroup, .collection:
        return nil
      }
    }
  }

  let kind: SharingNotificationKind
  let referrer: String
  let id: Identifier

  public static func == (lhs: SharingNotificationInfo, rhs: SharingNotificationInfo) -> Bool {
    return lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct SharingRequestNotification: DashlaneNotification {
  let state: NotificationCenterService.Notification.State
  let icon: SwiftUI.Image = Image.ds.action.share.outlined
  let title: String = L10n.Localizable.actionItemSharingTitle
  let description: String
  let category: NotificationCategory = .sharing
  let notificationActionHandler: NotificationActionHandler
  let kind: NotificationCenterService.Notification
  let id: String
  let creationDate: Date

  init(
    state: NotificationCenterService.Notification.State,
    creationDate: Date,
    notificationActionHandler: NotificationActionHandler,
    kind: SharingNotificationInfo.SharingNotificationKind,
    referrer: String,
    requestId: String,
    settingsPrefix: String
  ) {
    self.creationDate = creationDate
    self.state = state
    self.notificationActionHandler = notificationActionHandler
    self.id = settingsPrefix
    self.kind = .dynamic(.sharing(requestId: requestId, kind: kind))

    switch kind {
    case .item(let item) where item is Credential:
      self.description = L10n.Localizable.actionItemSharingDetail(referrer, item.localizedTitle)
    case .item(let item) where item is SecureNote:
      self.description = L10n.Localizable.actionItemSharingDetailSecurenote(referrer)
    case .userGroup:
      self.description = L10n.Localizable.actionItemSharingDetailGroup(referrer)
    case .collection(let name):
      self.description = CoreLocalization.L10n.Core.actionItemSharingDetailCollection(
        referrer, name)
    case .item:
      assertionFailure("Sharing this type of item isn't supported")
      self.description = ""
    }
  }

  init(
    info: SharingNotificationInfo,
    settings: NotificationSettings
  ) {
    self.init(
      state: settings.fetchState(),
      creationDate: settings.creationDate,
      notificationActionHandler: settings,
      kind: info.kind,
      referrer: info.referrer,
      requestId: info.id.rawValue,
      settingsPrefix: info.settingsPrefix)
  }
}
