import CoreLocalization
import CoreSettings
import DashTypes
import Foundation
import SwiftTreats
import UIKit

public struct RateAppViewModel: HomeAnnouncementsServicesInjecting {

  public enum Sender {
    case settings
    case braze
  }

  let login: Login
  let sender: Sender
  let userSettings: UserSettings

  public init(
    login: Login,
    sender: RateAppViewModel.Sender,
    userSettings: UserSettings
  ) {
    self.login = login
    self.sender = sender
    self.userSettings = userSettings
  }

  func rateApp() {
    guard let url = URL(string: "itms-apps://itunes.apple.com/app/id517914548?action=write-review")
    else {
      return
    }
    UIApplication.shared.open(url)
  }

  func makeMailViewModel() -> MailViewModel {
    let subject = [L10n.Core.kwFeedbackEmailSubject, Application.version(), System.version].joined(
      separator: "-")
    return MailViewModel(
      subject: subject,
      body: L10n.Core.kwFeedbackEmailBody(login),
      recipients: ["_"],
      logFilePath: nil)
  }

  func cancel() {
    guard sender == .braze else { return }
    userSettings[.rateAppDeclineResponseCount] =
      (userSettings[.rateAppDeclineResponseCount] ?? 0) + 1
  }

  func markRateAppHasBeenShown() {
    userSettings[.rateAppDidDisplay] = true
    userSettings[.rateAppLastVersion] = Application.version()
    userSettings[.rateAppLastDisplayedDate] = Date()
  }
}

extension RateAppViewModel {
  static var mock: RateAppViewModel {
    .init(
      login: .init("_"),
      sender: .braze,
      userSettings: .mock)
  }
}
