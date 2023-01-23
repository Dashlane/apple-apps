import Foundation

extension AnonymousEvent {

public struct `AutofillSubmitForm`: Encodable, AnonymousEventProtocol {
public static let isPriority = true
public init(`domain`: Definition.Domain, `fieldsDetectedByAnalysisEngineCount`: Int, `fieldsFilledBy`: Definition.FieldsFilledByCount, `formLoadedAtDateTime`: Date, `formSubmittedAtDateTime`: Date, `formType`: Definition.FormType, `hasModifiedInitiallyAutofilledValue`: Bool, `hasPasswordField`: Bool, `totalFormFieldsCount`: Int) {
self.domain = domain
self.fieldsDetectedByAnalysisEngineCount = fieldsDetectedByAnalysisEngineCount
self.fieldsFilledBy = fieldsFilledBy
self.formLoadedAtDateTime = formLoadedAtDateTime
self.formSubmittedAtDateTime = formSubmittedAtDateTime
self.formType = formType
self.hasModifiedInitiallyAutofilledValue = hasModifiedInitiallyAutofilledValue
self.hasPasswordField = hasPasswordField
self.totalFormFieldsCount = totalFormFieldsCount
}
public let domain: Definition.Domain
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
