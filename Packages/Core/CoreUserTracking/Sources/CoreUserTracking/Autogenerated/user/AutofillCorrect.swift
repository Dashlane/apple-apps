import Foundation

extension UserEvent {

public struct `AutofillCorrect`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`correctionType`: Definition.CorrectionType, `fieldCorrected`: Definition.ItemType, `initialFieldClassificationList`: [Definition.ItemType]? = nil, `newFieldClassification`: Definition.ItemType? = nil) {
self.correctionType = correctionType
self.fieldCorrected = fieldCorrected
self.initialFieldClassificationList = initialFieldClassificationList
self.newFieldClassification = newFieldClassification
}
public let correctionType: Definition.CorrectionType
public let fieldCorrected: Definition.ItemType
public let initialFieldClassificationList: [Definition.ItemType]?
public let name = "autofill_correct"
public let newFieldClassification: Definition.ItemType?
}
}
