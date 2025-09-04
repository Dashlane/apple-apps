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
    switch announcement {
    case .autorenewalFailedAnnouncement:
      failedAutoRenewalView
    case .specialOfferAnnouncement:
      specialOfferView
    case .premiumExpiredAnnouncement:
      premiumExpiredView
    case .premiumWillExpireAnnouncement:
      premiumWillExpireView
    case .passwordLimitReached:
      passwordLimitReachedView
    case .passwordLimitNearlyReached(let remainingItems):
      passwordLimitNearlyReachedView(remainingItems: remainingItems)
    }
  }

  var specialOfferView: some View {
    Infobox(
      CoreL10n.specialOfferAnnouncementTitle,
      description: CoreL10n.specialOfferAnnouncementBody
    ) {
      Button(CoreL10n.paywallUpgradetag) {
        self.model.showSettings()
      }
    }
  }

  var failedAutoRenewalView: some View {
    Infobox(CoreL10n.failedAutorenewalAnnouncementTitle) {
      Button(CoreL10n.failedAutorenewalAnnouncementAction) {
        self.model.openAppleUpdatePaymentsPage()
      }
    }
    .style(mood: .warning)
  }

  var premiumExpiredView: some View {
    Infobox(CoreL10n.announcePremiumExpiredBody) {
      premiumPurchaseCTA
    }
    .style(mood: .danger)
  }

  var premiumWillExpireView: some View {
    Infobox(model.premiumWillExpireTitle) {
      premiumPurchaseCTA
    }
    .style(mood: model.premiumWillExpireSoon ? .warning : .brand)
  }

  var premiumPurchaseCTA: some View {
    if model.isPremiumTrial {
      Button(CoreL10n.currentPlanCtaPremium) {
        model.showPremium()
      }
    } else {
      Button(CoreL10n.announcePremiumExpiredCta) {
        model.showPremium()
      }
    }
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
