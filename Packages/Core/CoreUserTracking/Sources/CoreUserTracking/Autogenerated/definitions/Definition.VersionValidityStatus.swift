import Foundation

extension Definition {

public enum `VersionValidityStatus`: String, Encodable {
case `expiredVersion` = "expired_version"
case `updateRecommended` = "update_recommended"
case `updateRequired` = "update_required"
case `updateStronglyEncouraged` = "update_strongly_encouraged"
}
}