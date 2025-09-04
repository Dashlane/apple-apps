import CoreLocalization
import Foundation

class RateAppConfig {

  let daysBeforeFirstRequest: String
  let daysForRequestFrequency: String
  let maxDeclineResponse: String
  let title: String
  let body: String
  let action: String
  let feedbackAction: String
  let declineAction: String
  let oneOffBlast: String?
  let controller: String?

  init(
    daysBeforeFirstRequest: String,
    daysForRequestFrequency: String,
    maxDeclineResponse: String,
    title: String,
    body: String,
    action: String,
    feedbackAction: String,
    declineAction: String,
    oneOffBlast: String?,
    controller: String?
  ) {
    self.daysBeforeFirstRequest = daysBeforeFirstRequest
    self.daysForRequestFrequency = daysForRequestFrequency
    self.maxDeclineResponse = maxDeclineResponse
    self.title = title
    self.body = body
    self.action = action
    self.feedbackAction = feedbackAction
    self.declineAction = declineAction
    self.oneOffBlast = oneOffBlast
    self.controller = controller
  }
}

extension RateAppConfig {
  static func `default`() -> RateAppConfig {
    RateAppConfig(
      daysBeforeFirstRequest: "7",
      daysForRequestFrequency: "60",
      maxDeclineResponse: "2",
      title: CoreL10n.kwSendLoveHeadingPasswordchanger,
      body: CoreL10n.kwSendLoveSubheadingPasswordchanger,
      action: CoreL10n.kwSendLoveSendlovebuttonPasswordchanger,
      feedbackAction: CoreL10n.kwSendLoveFeedbackbuttonPasswordchanger,
      declineAction: CoreL10n.kwSendLoveNothanksbuttonPasswordchanger,
      oneOffBlast: nil,
      controller: nil)
  }
}
