import Foundation

extension UserEvent {

public struct `ChangeProtectWithMasterPasswordSetting`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`flowStep`: Definition.FlowStep, `flowType`: Definition.FlowType, `settingLevel`: Definition.SettingLevel) {
self.flowStep = flowStep
self.flowType = flowType
self.settingLevel = settingLevel
}
public let flowStep: Definition.FlowStep
public let flowType: Definition.FlowType
public let name = "change_protect_with_master_password_setting"
public let settingLevel: Definition.SettingLevel
}
}
