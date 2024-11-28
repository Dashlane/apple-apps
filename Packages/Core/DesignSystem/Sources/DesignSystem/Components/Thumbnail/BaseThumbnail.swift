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
      .foregroundStyle(.clear)
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
    case .mini:
      0.8
    case .small:
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
    .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
    .controlSize(.mini)
    BaseThumbnail {
      EmptyView()
    }
    .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
    .controlSize(.small)
    BaseThumbnail {
      EmptyView()
    }
    .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
    BaseThumbnail {
      EmptyView()
    }
    .foregroundStyle(Color.ds.container.agnostic.neutral.standard)
    .controlSize(.large)
  }
}
