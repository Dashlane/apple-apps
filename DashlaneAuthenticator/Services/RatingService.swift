import Foundation
import Combine
import SwiftTreats
import DashTypes
import DashlaneAppKit

class RatingService {
    var requestRating = false
    
    enum Key: String, CustomStringConvertible {
        var description: String {
            return rawValue
        }
        case sessionCount
        case lastVersionPromptedForReview
    }
    
    @SharedUserDefault(key: Key.sessionCount, userDefaults: ApplicationGroup.authenticatorUserDefaults)
    var sessionCount: Int?
    
    @SharedUserDefault(key: Key.lastVersionPromptedForReview, userDefaults: ApplicationGroup.authenticatorUserDefaults)
    var lastVersionPromptedForReview: String?
    
    init() {
        start()
    }
    
    func start() {
                var count = sessionCount ?? 0
        count += 1
        sessionCount = count

                let currentVersion = Application.version()

                if count > 4 && currentVersion != lastVersionPromptedForReview {
            requestRating = true
        }
    }
    
    func update() {
        lastVersionPromptedForReview = Application.version()
        requestRating = false
    }
}
