import Foundation
import BrazeKit

public struct BrazeAnnouncement: Identifiable {
    let interactionLogger: BrazeAnnouncementLogger

    public let id: String
    let title: String
    let message: String
    let extra: BrazeAnnouncementExtraKeys
    let imageURL: URL?

    let primaryCTA: BrazeAnnouncementCTA
    let secondaryCTA: BrazeAnnouncementCTA?
}

extension BrazeAnnouncement {
    init(_ message: Braze.InAppMessage) throws {
                guard let modal = message.modal else {
            throw BrazeAnnouncementDecodingError.unhandledMessageType
        }
        self.interactionLogger = message

                self.id = UUID().uuidString

        self.title = modal.header
        self.message = modal.message
        let extraKeys = modal.extras
            .compactMapValues({ $0 as? String })
        self.extra = .init(extras: extraKeys)

        switch modal.buttons.count {
        case 1:
            self.primaryCTA = try .init(button: modal.buttons.last!)
            self.secondaryCTA = nil
        case 2:
            self.primaryCTA = try .init(button: modal.buttons.last!)
            self.secondaryCTA = try .init(button: modal.buttons.first!)
        default:
            throw BrazeAnnouncementDecodingError.wrongNumberOfButtons
        }

        self.imageURL = try modal.graphic?.imageURL()

        guard !isExcludedFromCurrentDevice() else {
            throw BrazeAnnouncementDecodingError.deviceIsExcludedFromAnnouncement
        }

        guard extra.announcementType == .modal else {
                                                                        throw BrazeAnnouncementDecodingError.unhandledMessageType
        }
    }
}

extension Braze.InAppMessage.Graphic {
    func imageURL() throws -> URL {
        switch self {
        case .image(let url):
            return url
        default:
            throw BrazeAnnouncementDecodingError.imageHavingWrongType
        }
    }
}

extension BrazeAnnouncement {
    func isExcludedFromCurrentDevice() -> Bool {
        return extra.excludedDevices.shouldExcludeCurrentDevice()
    }
}
