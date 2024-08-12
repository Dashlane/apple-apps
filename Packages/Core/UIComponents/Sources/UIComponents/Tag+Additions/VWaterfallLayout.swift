#if canImport(SwiftUI)
  import SwiftUI

  struct VWaterfallLayout: Layout {
    let spacing: Double

    struct Cache {
      var subviewBounds: [CGRect] = []
    }

    func makeCache(subviews: Subviews) -> Cache {
      var cache = Cache()
      for index in subviews.indices {
        cache.subviewBounds.append(
          .init(origin: .zero, size: subviews[index].sizeThatFits(.infinity)))
      }

      return cache
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize
    {
      let width = proposal.replacingUnspecifiedDimensions().width

      var currentOffsetX: Double = 0
      var currentOffsetY: Double = 0
      var maxY: Double = 0

      for index in cache.subviewBounds.indices {
        var bounds = cache.subviewBounds[index]

        if currentOffsetX + bounds.width >= width {
          currentOffsetX = 0
          currentOffsetY = maxY + spacing
        }

        maxY = max(currentOffsetY + bounds.height, maxY)

        bounds.origin.x = currentOffsetX
        bounds.origin.y = currentOffsetY

        cache.subviewBounds[index] = bounds

        currentOffsetX += bounds.width + spacing
      }

      return .init(width: width, height: maxY)
    }

    func placeSubviews(
      in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache
    ) {

      for index in cache.subviewBounds.indices {
        let elementBounds = cache.subviewBounds[index]
        let origin = CGPoint(
          x: bounds.origin.x + elementBounds.origin.x,
          y: bounds.origin.y + elementBounds.origin.y)

        subviews[index].place(
          at: origin, anchor: .topLeading,
          proposal: ProposedViewSize(width: elementBounds.width, height: elementBounds.height))
      }
    }
  }

  struct VWaterfallLayout_Previews: PreviewProvider {
    static let sizes: [Double] = [60, 100, 30, 40, 80, 46, 33, 90, 75, 23, 34]
    static var previews: some View {
      VWaterfallLayout(spacing: 10) {
        ForEach(sizes, id: \.self) { size in
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .frame(width: size, height: 30)
            .foregroundStyle(
              Color.random.gradient
                .shadow(.inner(color: .white.opacity(0.7), radius: 3, y: -1))
                .shadow(.inner(color: .black.opacity(0.4), radius: 1, y: -1))
                .shadow(.drop(radius: 2, y: 2))
            )

        }
      }
      .frame(width: 300)
      .previewLayout(.sizeThatFits)

      VWaterfallLayout(spacing: 10) {
        EmptyView()
      }
      .frame(minWidth: 10, minHeight: 10)
      .previewDisplayName("Empty")
      .previewLayout(.sizeThatFits)

    }
  }
#endif
