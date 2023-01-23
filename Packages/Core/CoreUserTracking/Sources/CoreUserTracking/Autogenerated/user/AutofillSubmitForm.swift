import Foundation

extension UserEvent {

public struct `AutofillSubmitForm`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`fieldsDetectedByAnalysisEngineCount`: Int, `fieldsFilledBy`: Definition.FieldsFilledByCount, `formLoadedAtDateTime`: Date, `formSubmittedAtDateTime`: Date, `formType`: Definition.FormType, `hasModifiedInitiallyAutofilledValue`: Bool, `hasPasswordField`: Bool, `totalFormFieldsCount`: Int) {
self.fieldsDetectedByAnalysisEngineCount = fieldsDetectedByAnalysisEngineCount
self.fieldsFilledBy = fieldsFilledBy
self.formLoadedAtDateTime = formLoadedAtDateTime
self.formSubmittedAtDateTime = formSubmittedAtDateTime
self.formType = formType
self.hasModifiedInitiallyAutofilledValue = hasModifiedInitiallyAutofilledValue
self.hasPasswordField = hasPasswordField
self.totalFormFieldsCount = totalFormFieldsCount
}
public let fieldsDetectedByAnalysisEngineCount: Int
public let fieldsFilledBy: Definition.FieldsFilledByCount
public let formLoadedAtDateTime: Date
public let formSubmittedAtDateTime: Date
public let formType: Definition.FormType
public let hasModifiedInitiallyAutofilledValue: Bool
public let hasPasswordField: Bool
public let name = "autofill_submit_form"
public let totalFormFieldsCount: Int
}
}
