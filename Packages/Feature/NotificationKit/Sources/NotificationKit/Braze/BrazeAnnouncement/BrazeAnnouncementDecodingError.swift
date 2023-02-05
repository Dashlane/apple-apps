import Foundation

enum BrazeAnnouncementDecodingError: Error {
    case unhandledMessageType
    case wrongNumberOfButtons
    case missingURLActionInButton
    case urlActionNotRedirectingToDashlane
    case imageHavingWrongType
    case deviceIsExcludedFromAnnouncement
}

