import CoreSettings
import Foundation

class GuidedOnboardingSettingsProvider: GuidedOnboardingDataProvider {

  private let userSettings: UserSettings

  var storedAnswers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer] {
    guard let savedAnswers: [GuidedOnboardingSettingsData] = userSettings[.guidedOnboardingData]
    else {
      return [:]
    }

    return
      savedAnswers
      .map { data -> (GuidedOnboardingQuestion, GuidedOnboardingAnswer)? in
        guard let question = GuidedOnboardingQuestion(rawValue: data.questionId),
          let answerId = data.answerId, let answer = GuidedOnboardingAnswer(rawValue: answerId)
        else {
          return nil
        }

        return (question, answer)
      }
      .compactMap({ $0 })
      .reduce(into: [:]) { $0[$1.0] = $1.1 }
  }

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    NSKeyedUnarchiver.setClass(
      GuidedOnboardingSettingsData.self, forClassName: "Dashlane.GuidedOnboardingSettingsData")
    NSKeyedUnarchiver.setClass(
      GuidedOnboardingSettingsData.self, forClassName: "DashlaneAppKit.GuidedOnboardingSettingsData"
    )
  }

  func storeAnswers(answers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer]) {
    let updatedSelectedAnswers = answers
    let convertibleAnswers = updatedSelectedAnswers.map {
      (keyValue) -> GuidedOnboardingSettingsData in
      let (question, answer) = keyValue
      return GuidedOnboardingSettingsData(questionId: question.rawValue, answerId: answer.rawValue)
    }
    userSettings[.guidedOnboardingData] = convertibleAnswers
  }

  func removeStoredAnswers() {
    userSettings.deleteValue(for: .guidedOnboardingData)
  }
}
