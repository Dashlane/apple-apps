import Foundation

extension AnonymousEvent {

  public struct `AutofillCorrect`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `correctionType`: Definition.CorrectionType, `domain`: Definition.Domain,
      `fieldCorrected`: Definition.ItemType,
      `initialFieldClassificationList`: [Definition.ItemType]? = nil,
      `isNativeApp`: Bool, `newFieldClassification`: Definition.ItemType? = nil
    ) {
      self.correctionType = correctionType
      self.domain = domain
      self.fieldCorrected = fieldCorrected
      self.initialFieldClassificationList = initialFieldClassificationList
      self.isNativeApp = isNativeApp
      self.newFieldClassification = newFieldClassification
    }
    public let correctionType: Definition.CorrectionType
    public let domain: Definition.Domain
    public let fieldCorrected: Definition.ItemType
    public let initialFieldClassificationList: [Definition.ItemType]?
    public let isNativeApp: Bool
    public let name = "autofill_correct"
    public let newFieldClassification: Definition.ItemType?
  }
}
