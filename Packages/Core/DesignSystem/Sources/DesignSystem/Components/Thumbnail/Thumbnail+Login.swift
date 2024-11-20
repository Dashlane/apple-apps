import Foundation
import SwiftUI

extension Thumbnail {
  public static func login(_ image: Image?) -> some View {
    BaseThumbnail {
      LoginThumbnailContentView(image: image)
    }
  }
}

private struct LoginThumbnailContentView: View {
  let image: Image?

  var body: some View {
    if let image {
      SquircleImageThumbnailContentView(image)
    } else {
      IconThumbnailContentView(Image.ds.web.outlined)
        .background {
          Rectangle()
            .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
        }
    }
  }
}

#Preview("Login") {
  HStack {
    Thumbnail.login(Image(.backgroundimage))
      .controlSize(.mini)
    Thumbnail.login(Image(.backgroundimage))
      .foregroundStyle(.purple)
      .controlSize(.regular)
    Thumbnail.login(Image(.backgroundimage))
      .foregroundStyle(.cyan)
      .controlSize(.large)
  }
}

#Preview("Group") {
  HStack {
    Thumbnail.login(nil)
      .controlSize(.mini)
    Thumbnail.login(nil)
      .controlSize(.regular)
    Thumbnail.login(nil)
      .controlSize(.large)
  }
}
