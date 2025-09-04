import CoreLocalization
import CorePasswords
import CoreSpotlight
import Foundation
import SwiftTreats
import SwiftUI

extension PasswordGeneratorView {
  static func update(_ activity: NSUserActivity) {
    activity.title = CoreL10n.kwCorespotlightTitlePasswordgenerator

    let set = CSSearchableItemAttributeSet(contentType: UTType.item)
    set.title = CoreL10n.kwCorespotlightTitlePasswordgenerator
    set.contentDescription = CoreL10n.kwCorespotlightDescPasswordgenerator
    set.keywords = [
      CoreL10n.kwCorespotlightKwdPasswordGenerator,
      CoreL10n.kwCorespotlightKwdRandomPassword,
      CoreL10n.kwCorespotlightKwdGenerateStrongPassword,
      CoreL10n.kwCorespotlightKwdStrongPasswords,
      CoreL10n.kwCorespotlightKwdNewPassword,
      CoreL10n.kwCorespotlightKwdPasswordSecurity,
    ]
    set.url = URL(string: "_")
    activity.contentAttributeSet = set
    activity[.deeplink] = PasswordGenerator.deeplink
    activity.webpageURL = set.url
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true
    activity.isEligibleForPublicIndexing = true
  }
}
