import CoreLocalization
import CorePremium
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI

struct PremiumAnnouncementsView: View {
  @ObservedObject
  var model: PremiumAnnouncementsViewModel

  var body: some View {
    if let announcement = model.announcements.first {
      banner(for: announcement)
    }
  }

  @ViewBuilder
  func banner(for announcement: PremiumAnnouncement) -> some View {
    if announcement == PremiumAnnouncement.autorenewalFailedAnnouncement {
      failedAutoRenewalView
    } else if announcement == PremiumAnnouncement.specialOfferAnnouncement {
      specialOfferView
    } else if announcement == PremiumAnnouncement.premiumExpiredAnnouncement {
      premiumExpiredView
    } else if announcement == PremiumAnnouncement.premiumWillExpireAnnouncement {
      premiumWillExpireView
    } else if announcement == PremiumAnnouncement.passwordLimitReached {
      passwordLimitReachedView
    } else if case let PremiumAnnouncement.passwordLimitNearlyReached(remainingItems) = announcement
    {
      passwordLimitNearlyReachedView(remainingItems: remainingItems)
    }
  }

  var specialOfferView: some View {
    Infobox(
      L10n.Core.specialOfferAnnouncementTitle,
      description: L10n.Core.specialOfferAnnouncementBody
    ) {
      Button(L10n.Core.paywallUpgradetag) {
        self.model.showSettings()
      }
    }
  }

  var failedAutoRenewalView: some View {
    Infobox(L10n.Core.failedAutorenewalAnnouncementTitle) {
      Button(L10n.Core.failedAutorenewalAnnouncementAction) {
        self.model.openAppleUpdatePaymentsPage()
      }
    }
    .style(mood: .warning)
  }

  var premiumExpiredView: some View {
    Infobox(L10n.Core.announcePremiumExpiredBody) {
      Button(L10n.Core.announcePremiumExpiredCta) {
        model.showPremium()
      }
    }
    .style(mood: .danger)
  }

  var premiumWillExpireView: some View {
    Infobox(model.premiumWillExpireTitle) {
      Button(L10n.Core.announcePremiumExpiredCta) {
        model.showPremium()
      }
    }
    .style(mood: model.premiumWillExpireSoon ? .warning : .brand)
  }

  var passwordLimitReachedView: some View {
    PasswordLimitReachedAnnouncementView {
      model.showPremiumForPasswordLimitReached()
    }
  }

  func passwordLimitNearlyReachedView(remainingItems: Int) -> some View {
    PasswordLimitNearlyReachedAnnouncementView(remainingItems: remainingItems) {
      model.showPremiumForPasswordLimitNearlyReached()
    }
  }
}

#Preview {
  ScrollView {
    VStack {
      PremiumAnnouncementsView(model: .mock(announcements: [.specialOfferAnnouncement]))
      PremiumAnnouncementsView(model: .mock(announcements: [.premiumWillExpireAnnouncement]))
      PremiumAnnouncementsView(model: .mock(announcements: [.premiumExpiredAnnouncement]))
      PremiumAnnouncementsView(model: .mock(announcements: [.autorenewalFailedAnnouncement]))
      PremiumAnnouncementsView(model: .mock(announcements: [.passwordLimitReached]))
      PremiumAnnouncementsView(
        model: .mock(announcements: [.passwordLimitNearlyReached(remainingItems: 4)]))
      PremiumAnnouncementsView(model: .mock(announcements: []))
    }
  }
}
