import SwiftUI
import SwiftTreats
import DesignSystem
import UIComponents
import CoreLocalization

struct BrazeAnnouncementContainerView: View {

    let announcement: BrazeAnnouncement

    let dismiss: () -> Void

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        content
            .background(Color.ds.container.agnostic.neutral.supershy)
            .didAppear {
                announcement.interactionLogger.display()
            }
    }

    @ViewBuilder
    var content: some View {
        if !Device.isIpadOrMac {
                                    if dynamicTypeSize <= .xxLarge {
                BrazeAnnouncementView(announcement: announcement, dismiss: dismiss)
                    .bottomSheet([.medium])
            } else {
                BrazeAnnouncementScrolledView(announcement: announcement, dismiss: dismiss)
                    .bottomSheet([.large])
            }
        } else {
            BrazeAnnouncementiPadView(announcement: announcement, dismiss: dismiss)
        }
    }
}

private struct BrazeAnnouncementView: View {

    let announcement: BrazeAnnouncement
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
                header
            BrazeAnnouncementViewContent(announcement: announcement)
                .padding(.horizontal, 16)
            BrazeAnnouncementViewActions(announcement: announcement, dismiss: dismiss)
                .padding(.horizontal, 16)
        }
    }

        @ViewBuilder
    var header: some View {
        ZStack {
            if let imageURL = announcement.imageURL {
                GeometryReader { proxy in
                    AsyncImage(
                        url: imageURL,
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: proxy.size.width,
                                       maxHeight: proxy.size.height)
                        },
                        placeholder: {
                            Color.clear
                        }

                    )
                }
            }
        } .overlay(alignment: .topTrailing) {
            AnnouncementCloseButton(dismiss: dismiss)
        }
    }
}

private struct BrazeAnnouncementiPadView: View {

    let announcement: BrazeAnnouncement
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: nil) {
            header
            Spacer()
            BrazeAnnouncementViewContent(announcement: announcement)
                .padding(.horizontal, 16)
            Spacer()
            BrazeAnnouncementViewActions(announcement: announcement, dismiss: dismiss)
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)

    }

        @ViewBuilder
    var header: some View {
            ZStack {
                if let imageURL = announcement.imageURL {
                    AsyncImage(
                        url: imageURL,
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)

                        },
                        placeholder: {
                            Color.clear
                        }
                    )
                }
            }
        .frame(maxWidth: .infinity)
        .overlay(alignment: Device.isMac ? .topLeading : .topTrailing) {
            AnnouncementCloseButton(dismiss: dismiss)
        }
    }

}

private struct BrazeAnnouncementScrolledView: View {

    let announcement: BrazeAnnouncement
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            header
            ScrollView {
                announcementImage
                BrazeAnnouncementViewContent(announcement: announcement)
                    .padding(.horizontal, 8)
            }
            BrazeAnnouncementViewActions(announcement: announcement, dismiss: dismiss)
            .padding(.horizontal, 8)
        }

    }

    @ViewBuilder
    var header: some View {
        HStack {
            if Device.isMac {
                AnnouncementCloseButton(dismiss: dismiss)
                Spacer()
            } else {
                Spacer()
                AnnouncementCloseButton(dismiss: dismiss)
            }
        }
    }

    @ViewBuilder
    var announcementImage: some View {
        if let imageURL = announcement.imageURL {
                AsyncImage(
                    url: imageURL,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    },
                    placeholder: {
                        Color.clear
                    }

                )
        }
    }
}

private struct BrazeAnnouncementViewContent: View {

    let announcement: BrazeAnnouncement

    @ScaledMetric
    private var fontSize: CGFloat = 24

    var body: some View {
        VStack(spacing: 8) {
            Text(announcement.title)
                .font(DashlaneFont.custom(fontSize, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
            Text(announcement.message)
                .foregroundColor(.ds.text.neutral.standard)
                .font(.body)
        }
        .fixedSize(horizontal: false, vertical: true)
        .minimumScaleFactor(0.01)
        .multilineTextAlignment(.center)
    }
}

private struct BrazeAnnouncementViewActions: View {

    let announcement: BrazeAnnouncement
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            RoundedButton(announcement.primaryCTA.title, action: {
                announcement.primaryCTA.performAction()
                announcement.interactionLogger.tapped(button: announcement.primaryCTA)
                dismiss()
            })
            .roundedButtonLayout(.fill)
            .style(intensity: .catchy)
            if let secondary = announcement.secondaryCTA {
                RoundedButton(secondary.title, action: {
                    secondary.performAction()
                    announcement.interactionLogger.tapped(button: secondary)
                    dismiss()
                })
                .roundedButtonLayout(.fill)
                .style(intensity: .quiet)
            }
        }
    }
}

struct BrazeModalView_Previews: PreviewProvider {

    struct Container<Content: View>: View {

        let content: () -> Content

        var body: some View {
            Color.red.sheet(isPresented: .constant(true)) {
                content()
                    .bottomSheet([.medium])
            }
        }
    }

    struct LegacyContainer<Content: View>: View {

        let content: () -> Content

        var body: some View {
            Color.red
                .bottomSheet(isPresented: .constant(true)) {
                    content()
                }
        }
    }

    static var previews: some View {

        Container {
            BrazeAnnouncementContainerView(announcement: BrazeAnnouncement.singleActionMock, dismiss: { })
        }.previewDisplayName("[Sheet] Single action")

        Container {
            BrazeAnnouncementContainerView(announcement: BrazeAnnouncement.multipleActionsMock, dismiss: { })
        }.previewDisplayName("[Sheet] Multiple actions")

        LegacyContainer {
            BrazeAnnouncementContainerView(announcement: BrazeAnnouncement.multipleActionsMock, dismiss: { })
        }.previewDisplayName("[Legacy] Multiple actions")
    }
}
