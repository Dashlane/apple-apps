import Foundation

extension AnonymousEvent {

public struct `RightClickMenuAction`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`domain`: Definition.Domain, `fieldFilled`: Definition.ItemType? = nil, `fieldInitialClassificationList`: [Definition.ItemType]? = nil, `isFieldDetectedByAnalysisEngine`: Bool, `isNativeApp`: Bool, `rightClickMenuFlowStep`: Definition.RightClickMenuFlowStep) {
self.domain = domain
self.fieldFilled = fieldFilled
self.fieldInitialClassificationList = fieldInitialClassificationList
self.isFieldDetectedByAnalysisEngine = isFieldDetectedByAnalysisEngine
self.isNativeApp = isNativeApp
self.rightClickMenuFlowStep = rightClickMenuFlowStep
}
public let domain: Definition.Domain
public let fieldFilled: Definition.ItemType?
public let fieldInitialClassificationList: [Definition.ItemType]?
public let isFieldDetectedByAnalysisEngine: Bool
public let isNativeApp: Bool
public let name = "right_click_menu_action"
public let rightClickMenuFlowStep: Definition.RightClickMenuFlowStep
}
}
