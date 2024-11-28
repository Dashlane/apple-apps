import Foundation
import SwiftUI

public enum Thumbnail: View {
  case icon(Image)

  public var body: some View {
    switch self {
    case .icon(let icon):
      BaseThumbnail {
        IconThumbnailContentView(icon)
      }
      .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
    }
  }
}

#Preview {
  HStack {
    Thumbnail.icon(.ds.action.add.outlined)
      .controlSize(.mini)
    Thumbnail.icon(.ds.action.add.outlined)
      .controlSize(.regular)
    Thumbnail.icon(.ds.action.add.outlined)
      .controlSize(.large)
  }
}
