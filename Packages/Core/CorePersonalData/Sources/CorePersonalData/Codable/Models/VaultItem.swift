import DashlaneAPI
import SwiftUI

public protocol VaultItem: Displayable,
  DatedPersonalData,
  DocumentAttachable,
  AuditLogReportableItem
{
  static var localizedName: String { get }
  static var addIcon: SwiftUI.Image { get }
  static var addTitle: String { get }
  static var nativeMenuAddTitle: String { get }

  var enumerated: VaultItemEnumeration { get }

  var localizedTitle: String { get }
  var localizedSubtitle: String { get }

  var icon: VaultItemIcon { get }
  var subtitleImage: SwiftUI.Image? { get }
  var subtitleFont: Font? { get }

  var creationDatetime: Date? { get set }
  var userModificationDatetime: Date? { get set }

  var spaceId: String? { get set }

  var limitedRightsAlertTitle: String { get }

  init()

  func matchCriteria(_ criteria: String) -> SearchMatch?

  func isAssociated(to: PremiumStatusTeamInfo) -> Bool
}

extension VaultItem {
  public var displayTitle: String {
    localizedTitle
  }

  public var displaySubtitle: String? {
    localizedSubtitle
  }

  public var subtitleImage: SwiftUI.Image? {
    return nil
  }

  public var subtitleFont: Font? {
    return nil
  }
}
