import Foundation

extension UserEvent {

  public struct `SubmitInProductFormAnswer`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `answerList`: [Definition.PossibleFormAnswers]? = nil,
      `chosenAnswerList`: [Definition.PossibleFormAnswers]? = nil, `formName`: Definition.FormName
    ) {
      self.answerList = answerList
      self.chosenAnswerList = chosenAnswerList
      self.formName = formName
    }
    public let answerList: [Definition.PossibleFormAnswers]?
    public let chosenAnswerList: [Definition.PossibleFormAnswers]?
    public let formName: Definition.FormName
    public let name = "submit_in_product_form_answer"
  }
}
