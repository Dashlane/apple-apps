import Foundation

enum BrazeAnnouncementDecodingError: Error {
    case unhandledMessageType
    case wrongNumberOfButtons
    case missingURLActionInButton
    case urlActionNotReditectingToDashlane
    case imageHavingWrongType
    case deviceIsExcludedFromAnnouncement
}

