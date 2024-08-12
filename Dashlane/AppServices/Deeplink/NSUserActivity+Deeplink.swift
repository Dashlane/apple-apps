import CoreSpotlight
import Foundation

extension NSUserActivity {

  var isFromUniversalLink: Bool {
    return activityType == NSUserActivityTypeBrowsingWeb
  }

  var isSpotlightResult: Bool {
    return activityType == CSSearchableItemActionType
  }

  var isSearchContinuation: Bool {
    return activityType == CSQueryContinuationActionType
  }

  var isPasswordGenerationIntent: Bool {
    return activityType == "GeneratePasswordIntent"
  }
}
