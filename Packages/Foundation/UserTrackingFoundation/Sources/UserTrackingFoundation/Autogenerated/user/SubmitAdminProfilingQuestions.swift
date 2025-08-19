import Foundation

extension UserEvent {

  public struct `SubmitAdminProfilingQuestions`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `adminFamiliarityAnswerList`: [Definition.ProfilingFamiliarityPossibleAnswers]? = nil,
      `adminFamiliarityChoiceList`: [Definition.ProfilingFamiliarityPossibleAnswers]? = nil,
      `featuresAnswerList`: [Definition.ProfilingFeaturesPossibleAnswers]? = nil,
      `featuresChoiceList`: [Definition.ProfilingFeaturesPossibleAnswers]? = nil,
      `isProfilingComplete`: Bool,
      `profilingStep`: Definition.ProfilingStep,
      `teamSizeAnswerList`: [Definition.ProfilingTeamSizePossibleAnswers]? = nil,
      `teamSizeChoiceList`: [Definition.ProfilingTeamSizePossibleAnswers]? = nil,
      `useCaseAnswerList`: [Definition.ProfilingUseCasePossibleAnswers]? = nil,
      `useCaseChoiceList`: [Definition.ProfilingUseCasePossibleAnswers]? = nil
    ) {
      self.adminFamiliarityAnswerList = adminFamiliarityAnswerList
      self.adminFamiliarityChoiceList = adminFamiliarityChoiceList
      self.featuresAnswerList = featuresAnswerList
      self.featuresChoiceList = featuresChoiceList
      self.isProfilingComplete = isProfilingComplete
      self.profilingStep = profilingStep
      self.teamSizeAnswerList = teamSizeAnswerList
      self.teamSizeChoiceList = teamSizeChoiceList
      self.useCaseAnswerList = useCaseAnswerList
      self.useCaseChoiceList = useCaseChoiceList
    }
    public let adminFamiliarityAnswerList: [Definition.ProfilingFamiliarityPossibleAnswers]?
    public let adminFamiliarityChoiceList: [Definition.ProfilingFamiliarityPossibleAnswers]?
    public let featuresAnswerList: [Definition.ProfilingFeaturesPossibleAnswers]?
    public let featuresChoiceList: [Definition.ProfilingFeaturesPossibleAnswers]?
    public let isProfilingComplete: Bool
    public let name = "submit_admin_profiling_questions"
    public let profilingStep: Definition.ProfilingStep
    public let teamSizeAnswerList: [Definition.ProfilingTeamSizePossibleAnswers]?
    public let teamSizeChoiceList: [Definition.ProfilingTeamSizePossibleAnswers]?
    public let useCaseAnswerList: [Definition.ProfilingUseCasePossibleAnswers]?
    public let useCaseChoiceList: [Definition.ProfilingUseCasePossibleAnswers]?
  }
}
