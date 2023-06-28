import Foundation
import SwiftUI
import CoreSpotlight
import CoreLocalization
import CorePasswords
import SwiftTreats

#if !os(macOS)
extension PasswordGeneratorView {
    static func update(_ activity: NSUserActivity) {
        activity.title = L10n.Core.kwCorespotlightTitlePasswordgenerator

        let set = CSSearchableItemAttributeSet(contentType: UTType.item)
        set.title = L10n.Core.kwCorespotlightTitlePasswordgenerator
        set.contentDescription =  L10n.Core.kwCorespotlightDescPasswordgenerator
        set.keywords = [
            L10n.Core.kwCorespotlightKwdPasswordGenerator,
            L10n.Core.kwCorespotlightKwdRandomPassword,
            L10n.Core.kwCorespotlightKwdGenerateStrongPassword,
            L10n.Core.kwCorespotlightKwdStrongPasswords,
            L10n.Core.kwCorespotlightKwdNewPassword,
            L10n.Core.kwCorespotlightKwdPasswordSecurity
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
#endif
