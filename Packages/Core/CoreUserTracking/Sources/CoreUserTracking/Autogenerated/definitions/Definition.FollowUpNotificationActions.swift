import Foundation

extension Definition {

public enum `FollowUpNotificationActions`: String, Encodable {
case `activateFeature` = "activate_feature"
case `copy`
case `deactivateFeature` = "deactivate_feature"
case `dismiss`
case `trigger`
}
}