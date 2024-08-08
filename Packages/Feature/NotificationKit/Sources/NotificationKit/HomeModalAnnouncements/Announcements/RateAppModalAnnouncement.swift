import CoreSession
import CoreSettings
import DashTypes
import Foundation
import SwiftTreats
import UIKit

public class RateAppModalAnnouncement: HomeModalAnnouncement, HomeAnnouncementsServicesInjecting {

  private var rateConfig: RateAppConfig {
    RateAppConfig.default()
  }

  let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

  private let login: Login
  private let userSettings: UserSettings

  var isOneOffBlastMode: Bool {
    guard let oneOffBlast = self.rateConfig.oneOffBlast else {
      return false
    }

    guard let lastOneOffBlast: String = userSettings[.rateApplastOneOffBlast] else {
      return true
    }

    return oneOffBlast != lastOneOffBlast
  }

  public init(
    session: Session,
    userSettings: UserSettings
  ) {
    self.login = session.login
    self.userSettings = userSettings
  }

  func shouldDisplay() -> Bool {
    if isOneOffBlastMode {
      userSettings[.rateApplastOneOffBlast] = rateConfig.oneOffBlast
      return true
    }

    if (userSettings[.rateAppDeclineResponseCount] ?? 0) >= Int(rateConfig.maxDeclineResponse) ?? 0
    {
      return false
    }

    guard let rateAppDidDisplay: Bool = userSettings[.rateAppDidDisplay], rateAppDidDisplay else {
      guard let rateAppInstallDate: Date = userSettings[.rateAppInstallDate] else {
        userSettings[.rateAppInstallDate] = Date()
        return false
      }
      let timeSinceInstallDate = Date().timeIntervalSince(rateAppInstallDate)
      let timeIntervalfrequency = 60 * 60 * 24 * (Double(rateConfig.daysBeforeFirstRequest) ?? 0)
      if timeSinceInstallDate >= timeIntervalfrequency {
        return true
      }
      return false
    }

    let version = Application.version()
    if version != userSettings[.rateAppLastVersion] {
      guard let rateAppLastDisplayedDate: Date = userSettings[.rateAppLastDisplayedDate] else {
        userSettings[.rateAppLastDisplayedDate] = Date()
        return false
      }
      let timeSinceLastDisplayed = Date().timeIntervalSince(rateAppLastDisplayedDate)
      let timeIntervalfrequency = 60 * 60 * 24 * (Double(rateConfig.daysForRequestFrequency) ?? 0)
      if timeSinceLastDisplayed >= timeIntervalfrequency {
        return true
      }
    }

    return false
  }

  var announcement: HomeModalAnnouncementType? {
    guard shouldDisplay() else { return nil }
    return .overScreen(.rateApp)
  }
}

extension RateAppModalAnnouncement {
  static var mock: RateAppModalAnnouncement {
    .init(session: .mock, userSettings: .mock)
  }
}
