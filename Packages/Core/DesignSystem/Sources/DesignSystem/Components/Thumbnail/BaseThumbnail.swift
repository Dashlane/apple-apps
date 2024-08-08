import Foundation
import SwiftUI

struct BaseThumbnail<Content: View>: View {
  @Environment(\.controlSize) private var controlSize
  private let baseDimension = 40.0
  private let strokeLineWidth = 1.0

  private let content: Content

  init(@ViewBuilder _ content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    Rectangle()
      .frame(width: effectiveDimension, height: effectiveDimension)
      .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
      .overlay(content)
      .overlay(
        ThumbnailShape()
          .stroke(
            Color.ds.border.neutral.quiet.idle,
            lineWidth: effectiveStrokeLineWidth * 2
          )
      )
      .mask(ThumbnailShape())
      .accessibilityHidden(true)
  }

  private var effectiveStrokeLineWidth: Double {
    return strokeLineWidth * controlSize.thumbnailScaleValue
  }

  private var effectiveDimension: Double {
    return baseDimension * controlSize.thumbnailScaleValue
  }
}

extension ControlSize {
  var thumbnailScaleValue: Double {
    switch self {
    case .mini, .small:
      1
    case .regular:
      1.5
    case .large, .extraLarge:
      2
    @unknown default:
      1
    }
  }
}

#Preview {
  HStack(spacing: 20) {
    BaseThumbnail {
      EmptyView()
    }
    .controlSize(.small)
    BaseThumbnail {
      EmptyView()
    }
    BaseThumbnail {
      EmptyView()
    }
    .controlSize(.large)
  }
}
