import SwiftUI

extension Thumbnail {
  public static var collection: some View {
    BaseThumbnail {
      IconThumbnailContentView(Image.ds.collection.outlined)
        .background {
          Rectangle()
            .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
        }
    }
  }
}

#Preview {
  HStack {
    Thumbnail.collection
      .controlSize(.small)
    Thumbnail.collection
      .controlSize(.regular)
    Thumbnail.collection
      .controlSize(.large)
  }
}
