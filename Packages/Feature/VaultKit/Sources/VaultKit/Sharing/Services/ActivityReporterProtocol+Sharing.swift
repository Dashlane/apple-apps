import CoreUserTracking
import DashTypes
import Foundation

extension ActivityReporterProtocol {
  var sharing: SharingActivityReporter {
    return SharingActivityReporter(reporter: self)
  }
}

struct SharingActivityReporter {
  let reporter: ActivityReporterProtocol
  public func reportCreate(
    with items: [VaultItem],
    userRecipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission,
    success: Bool
  ) {

    items.forEach { item in
      guard let type = item.metadata.contentType.sharingType else {
        return
      }

      reporter.report(
        UserEvent.ShareItem(
          groupsCount: userGroupIds.count,
          individualsCount: userRecipients.count - 1,
          itemType: .init(type),
          requestStatus: success ? .shared : .error,
          rights: .init(permission: permission)))
    }
  }

  public func reportPermissionUpdate(
    of item: VaultItem,
    to permission: SharingPermission,
    success: Bool
  ) {
    guard let type = item.metadata.contentType.sharingType else {
      return
    }

    reporter.report(
      UserEvent.UpdateSharedItem(
        itemType: .init(type),
        rights: .init(permission: permission),
        updateStatus: success ? .updated : .error))
  }

  public func reportRevoke(of item: VaultItem, success: Bool) {
    guard let type = item.metadata.contentType.sharingType else {
      return
    }

    reporter.report(
      UserEvent.UpdateSharedItem(
        itemType: .init(type),
        rights: .revoked,
        updateStatus: success ? .updated : .error))
  }

  public func reportPendingItemGroupResponse(
    for item: VaultItem,
    accepted: Bool,
    success: Bool
  ) {
    let response: Definition.ResponseStatus
    guard let permission = item.metadata.sharingPermission,
      let type = item.metadata.contentType.sharingType
    else {
      return
    }

    if !success {
      response = .error
    } else {
      response = accepted ? .accepted : .denied
    }

    reporter.report(
      UserEvent.RespondSharedItem(
        hasAccepted: accepted,
        itemType: .init(type),
        responseStatus: response,
        rights: .init(permission: permission)))
  }

}

extension Definition.Rights {
  fileprivate init(permission: SharingPermission) {
    switch permission {
    case .admin:
      self = .unlimited
    case .limited:
      self = .limited
    }
  }
}

extension Definition.SharingItemType {
  fileprivate init(_ type: SharingType) {
    switch type {
    case .password:
      self = .credential
    case .note:
      self = .secureNote
    case .secret:
      self = .secureNote
    }
  }
}
