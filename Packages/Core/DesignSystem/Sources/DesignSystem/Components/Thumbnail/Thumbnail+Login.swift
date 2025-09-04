import Foundation
import SwiftUI

extension Thumbnail {

  @ViewBuilder
  public static func login(_ image: Image?) -> some View {
    if let image {
      BaseThumbnail {
        SquircleImageThumbnailContentView(image)
      }
    } else {
      Thumbnail.VaultItem.login
    }
  }
}

#Preview("Login with image") {
  HStack {
    Thumbnail.login(Image(.backgroundimage))
      .controlSize(.small)
    Thumbnail.login(Image(.backgroundimage))
      .foregroundStyle(.purple)
      .controlSize(.regular)
    Thumbnail.login(Image(.backgroundimage))
      .foregroundStyle(.cyan)
      .controlSize(.large)
  }
}

#Preview("Login w/o image") {
  HStack {
    Thumbnail.login(nil)
      .controlSize(.small)
    Thumbnail.login(nil)
      .controlSize(.regular)
    Thumbnail.login(nil)
      .controlSize(.large)
  }
}
