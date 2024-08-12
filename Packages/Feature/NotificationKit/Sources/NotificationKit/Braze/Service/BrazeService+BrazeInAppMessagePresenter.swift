import BrazeKit
import BrazeUI
import Foundation

extension BrazeService: BrazeInAppMessagePresenter {

  public func present(message: BrazeKit.Braze.InAppMessage) {
    do {
      let announcement = try BrazeAnnouncement(message)
      self.modals.append(announcement)
    } catch BrazeAnnouncementDecodingError.deviceIsExcludedFromAnnouncement {
      message.discard()
      logger.debug("This device is excluded from the campaign.")
    } catch BrazeAnnouncementDecodingError.unhandledMessageType {
      assertionFailure("Unhandled campaign type")
    } catch {
      assertionFailure("The decode should never fail, did the specs change?")
      logger.error("Couldn'd decode IAM: \(error)")
    }
  }
}
