import Foundation

extension Definition {

public enum `B2BPlanTier`: String, Encodable {
case `business`
case `legacy`
case `starterTeam` = "starter_team"
case `team`
}
}