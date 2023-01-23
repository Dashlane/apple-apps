import Foundation

extension UserEvent {

public struct `RightClickMenuAction`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`fieldFilled`: Definition.ItemType? = nil, `fieldInitialClassificationList`: [Definition.ItemType]? = nil, `isFieldDetectedByAnalysisEngine`: Bool, `rightClickMenuFlowStep`: Definition.RightClickMenuFlowStep) {
self.fieldFilled = fieldFilled
self.fieldInitialClassificationList = fieldInitialClassificationList
self.isFieldDetectedByAnalysisEngine = isFieldDetectedByAnalysisEngine
self.rightClickMenuFlowStep = rightClickMenuFlowStep
}
public let fieldFilled: Definition.ItemType?
public let fieldInitialClassificationList: [Definition.ItemType]?
public let isFieldDetectedByAnalysisEngine: Bool
public let name = "right_click_menu_action"
public let rightClickMenuFlowStep: Definition.RightClickMenuFlowStep
}
}
