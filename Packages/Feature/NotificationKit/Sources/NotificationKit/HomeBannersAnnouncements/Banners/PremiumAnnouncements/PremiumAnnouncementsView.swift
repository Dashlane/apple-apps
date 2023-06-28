import Foundation
import SwiftUI
import SwiftTreats
import CorePremium
import CoreLocalization

struct PremiumAnnouncementsView: View {
    @ObservedObject
    var model: PremiumAnnouncementsViewModel

    var body: some View {
        if !model.announcements.isEmpty {
            banner
        }
    }

    @ViewBuilder
    var banner: some View {
        ZStack {
            if model.announcements.first == PremiumAnnouncement.autorenewalFailedAnnouncement {
                failedAutoRenewalView
            } else if model.announcements.first == PremiumAnnouncement.specialOfferAnnouncement {
                specialOfferView
            } else if model.announcements.first == PremiumAnnouncement.premiumExpiredAnnouncement {
                premiumExpiredView
            } else if model.announcements.first == PremiumAnnouncement.premiumWillExpireAnnouncement {
                premiumWillExpireView
            } else {
                EmptyView()
            }
        }
        .buttonStyle(AnnouncementButtonStyle())
        .foregroundColor(.ds.text.neutral.standard)
        .accentColor(.ds.text.neutral.standard)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .background(.ds.container.expressive.neutral.quiet.idle)
    }

    var specialOfferView: some View {
        Announcement(title: Text(L10n.Core.specialOfferAnnouncementTitle),
                     subTitle: Text(L10n.Core.specialOfferAnnouncementBody))
            .onTapGesture {
                self.model.showSettings()
        }
    }

    var failedAutoRenewalView: some View {
        Announcement(subTitle: Text(L10n.Core.failedAutorenewalAnnouncementTitle),
                     button: Button(L10n.Core.failedAutorenewalAnnouncementAction, action: { self.model.openAppleUpdatePaymentsPage() }))
    }

    var premiumExpiredView: some View {
        Announcement(subTitle: Text(L10n.Core.announcePremiumExpiredBody),
                     button: Button(L10n.Core.announcePremiumExpiredCta, action: { model.showPremium() }))
    }

    var premiumWillExpireView: some View {
        Announcement(subTitle: Text(model.premiumWillExpireTitle),
                     button: Button(L10n.Core.announcePremiumExpiredCta, action: { model.showPremium() }))
    }
}

private struct DismissableAnnouncementModifier: ViewModifier {

    let dismiss: () -> Void

    func body(content: Content) -> some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            content
        }
    }
}

internal extension View {
    func dismissable(_ dismiss: @escaping () -> Void) -> some View {
        self.modifier(DismissableAnnouncementModifier(dismiss: dismiss))
    }

}

struct Announcement: View {
    let title: Text?
    let subTitle: Text
    let button: Button<Text>?
    let image: ImageAsset?

    init(title: Text? = nil,
         subTitle: Text,
         image: ImageAsset? = nil,
         button: Button<Text>? = nil) {
        self.title = title
        self.image = image
        self.subTitle = subTitle
        self.button = button
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if let imageAsset = image {
                Image(asset: imageAsset)
                    .resizable()
                    .frame(width: 175, height: 30)
            }
            if title != nil {
                title
                    .multilineTextAlignment(.center)
                    .font(.headline)
            }
            subTitle
                .multilineTextAlignment(.center)
                .font(.body)
            if button != nil {
                button
            }
        }
    }
}

struct PremiumAnnouncementsView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PremiumAnnouncementsView(model: .mock(announcements:
                [
                    .specialOfferAnnouncement
            ]))
            PremiumAnnouncementsView(model: .mock(announcements:
                [
                    .premiumWillExpireAnnouncement
            ]))

            PremiumAnnouncementsView(model: .mock(announcements:
                [
                    .premiumExpiredAnnouncement
            ]))

            PremiumAnnouncementsView(model: .mock(announcements:
                [
                    .autorenewalFailedAnnouncement
            ]))
            PremiumAnnouncementsView(model: .mock(announcements:
                [
            ]))
        }.previewLayout(.sizeThatFits)

    }
}

struct AnnouncementButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.ds.text.brand.standard)
            .font(.headline)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
