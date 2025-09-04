import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents

struct BrazeAnnouncementContainerView: View {

  let announcement: BrazeAnnouncement

  let dismiss: () -> Void

  @Environment(\.dynamicTypeSize) var dynamicTypeSize

  var body: some View {
    content
      .background(Color.ds.container.agnostic.neutral.supershy)
      .onAppear {
        announcement.interactionLogger.display()
      }
  }

  @ViewBuilder
  var content: some View {
    if !Device.is(.pad, .mac, .vision) {
      if dynamicTypeSize <= .xxLarge {
        BrazeAnnouncementScrolledView(announcement: announcement, dismiss: dismiss)
          .presentationDetents([.medium])
      } else {
        BrazeAnnouncementScrolledView(announcement: announcement, dismiss: dismiss)
          .presentationDetents([.large])
      }
    } else {
      BrazeAnnouncementiPadView(announcement: announcement, dismiss: dismiss)
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
        BrazeAnnouncementViewContent(announcement: announcement)
          .padding(.horizontal, 8)
      }
      BrazeAnnouncementViewActions(announcement: announcement, dismiss: dismiss)
        .padding(.horizontal, 16)
    }

  }

  @ViewBuilder
  var header: some View {
    ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
      announcementImage
      AnnouncementCloseButton(dismiss: dismiss)
        .frame(maxWidth: .infinity, alignment: Device.is(.mac) ? .leading : .trailing)
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
          EmptyView()
        }

      )
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
    .overlay(alignment: Device.is(.mac) ? .topLeading : .topTrailing) {
      AnnouncementCloseButton(dismiss: dismiss)
    }
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
            EmptyView()
          }
        )
      }
    }
    .frame(maxWidth: .infinity)
  }

}

private struct BrazeAnnouncementViewContent: View {

  let announcement: BrazeAnnouncement

  var body: some View {
    VStack(spacing: 8) {
      Text(announcement.title)
        .textStyle(.title.section.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(announcement.message)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .textStyle(.body.standard.regular)
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
      Button(announcement.primaryCTA.title) {
        announcement.primaryCTA.performAction()
        announcement.interactionLogger.tapped(button: announcement.primaryCTA)
        dismiss()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(intensity: .catchy)
      .accessibilityIdentifier("Braze Primary button")
      if let secondary = announcement.secondaryCTA {
        Button(secondary.title) {
          secondary.performAction()
          announcement.interactionLogger.tapped(button: secondary)
          dismiss()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .quiet)
        .accessibilityIdentifier("Braze Secondary button")
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
      }
    }
  }

  static var previews: some View {

    Container {
      BrazeAnnouncementContainerView(announcement: BrazeAnnouncement.singleActionMock, dismiss: {})
    }.previewDisplayName("[Sheet] Single action")

    Container {
      BrazeAnnouncementContainerView(
        announcement: BrazeAnnouncement.singleActionLongMessageMock, dismiss: {})
    }.previewDisplayName("[Sheet] Single action, long message")

    Container {
      BrazeAnnouncementContainerView(
        announcement: BrazeAnnouncement.multipleActionsMock, dismiss: {})
    }.previewDisplayName("[Sheet] Multiple actions")
  }
}
