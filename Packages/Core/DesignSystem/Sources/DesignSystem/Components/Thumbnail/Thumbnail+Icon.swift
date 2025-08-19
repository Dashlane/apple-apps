import SwiftUI

struct IconThumbnailContentView: View {
  @Environment(\.controlSize) private var controlSize
  private let padding = 10.0

  private let icon: Image

  init(_ icon: Image) {
    self.icon = icon
  }

  var body: some View {
    icon
      .resizable()
      .aspectRatio(contentMode: .fit)
      .foregroundStyle(Color.ds.text.neutral.quiet)
      .padding(padding * controlSize.thumbnailScaleValue)
  }
}

struct SquircleIconThumbnailContentView: View {
  @Environment(\.controlSize) private var controlSize
  private let outerPadding = 8.0
  private let innerPadding = 4.0

  private let icon: Image

  init(_ icon: Image) {
    self.icon = icon
  }

  var body: some View {
    Rectangle()
      .opacity(0.25)
      .overlay(
        Squircle()
          .opacity(0.9)
          .overlay(
            icon
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundStyle(Color.ds.text.inverse.catchy)
              .padding(innerPadding * controlSize.thumbnailScaleValue)
          )
          .padding(outerPadding * controlSize.thumbnailScaleValue)
      )
  }
}

struct SquircleImageThumbnailContentView: View {
  @Environment(\.controlSize) private var controlSize
  private let outerPadding = 8.0

  private let image: Image

  init(_ image: Image) {
    self.image = image
  }

  var body: some View {
    Rectangle()
      .opacity(0.25)
      .overlay(
        Rectangle()
          .opacity(0)
          .overlay(
            image
              .resizable()
              .renderingMode(.original)
              .aspectRatio(contentMode: .fill)
          )
          .mask(Squircle())
          .padding(outerPadding * controlSize.thumbnailScaleValue)
      )
  }
}

#Preview("IconThumbnailContentView") {
  HStack {
    BaseThumbnail {
      IconThumbnailContentView(.ds.accountSettings.outlined)
    }
    .foregroundStyle(.red)

    BaseThumbnail {
      IconThumbnailContentView(.ds.accountSettings.outlined)
    }
    .foregroundStyle(.green)
  }
}

#Preview("SquircleIconThumbnailContentView") {
  HStack {
    BaseThumbnail {
      SquircleIconThumbnailContentView(.ds.accountSettings.outlined)
    }
    .foregroundStyle(Color.ds.container.decorative.grey)

    BaseThumbnail {
      SquircleIconThumbnailContentView(.ds.accountSettings.outlined)
    }
    .foregroundStyle(.red)

    BaseThumbnail {
      SquircleIconThumbnailContentView(.ds.accountSettings.outlined)
    }
    .foregroundStyle(.green)
  }
}

#Preview("SquircleImageThumbnailContentView") {
  HStack {
    BaseThumbnail {
      SquircleImageThumbnailContentView(Image(.backgroundimage))
    }
    .foregroundStyle(.red)

    BaseThumbnail {
      SquircleImageThumbnailContentView(Image(.backgroundimage))
    }
    .foregroundStyle(.green)
  }
}
