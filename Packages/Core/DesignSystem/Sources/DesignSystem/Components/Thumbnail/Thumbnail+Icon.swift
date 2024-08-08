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
