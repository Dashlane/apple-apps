import SwiftUI

extension Thumbnail {
  public static var collection: some View {
    BaseThumbnail {
      IconThumbnailContentView(Image.ds.collection.outlined)
    }
  }
}

#Preview {
  HStack {
    Thumbnail.collection
      .controlSize(.mini)
    Thumbnail.collection
      .controlSize(.regular)
    Thumbnail.collection
      .controlSize(.large)
  }
}
