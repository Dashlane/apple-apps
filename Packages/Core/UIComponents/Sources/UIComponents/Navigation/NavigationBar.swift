import MapKit
import SwiftUI
import UIDelight

public let navigationBarMinHeight: CGFloat = 40

public struct NavigationBar<Leading: View, Title: View, TitleAccessory: View, Trailing: View>: View
{
  let leading: Leading
  let title: Title
  let titleAccessory: TitleAccessory
  let trailing: Trailing
  let height: CGFloat

  private var isCollapsed: Bool {
    height <= navigationBarMinHeight
  }

  public init(
    leading: Leading,
    title: Title,
    titleAccessory: TitleAccessory,
    trailing: Trailing,
    height: CGFloat? = navigationBarMinHeight
  ) {
    self.leading = leading
    self.title = title
    self.titleAccessory = titleAccessory
    self.trailing = trailing
    self.height = height ?? navigationBarMinHeight
  }

  public var body: some View {
    NavigationBarLayout {
      self.leading
        .fixedSize()
        .lineLimit(1)
        .layoutPriority(2)

      center

      self.trailing
        .fixedSize()
        .lineLimit(1)
        .layoutPriority(2)
    }
    .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    .font(.system(size: 17))
    .frame(height: height)
    .frame(maxWidth: .infinity)
    .background(.ds.container.agnostic.neutral.standard.edgesIgnoringSafeArea(.top))
    .animation(.spring(), value: isCollapsed)
  }

  @ViewBuilder
  private var center: some View {
    self.title
      .font(.system(size: 17).weight(.semibold))
      .multilineTextAlignment(.center)
      .lineLimit(2)
      .padding(.vertical, 8)
      .padding(.horizontal, 5)
      .background(accessory.alignmentGuide(.top, to: .bottom), alignment: .top)
      .frame(minHeight: navigationBarMinHeight)
      .accessibilityAddTraits(.isHeader)
  }

  @ViewBuilder
  private var accessory: some View {
    if !isCollapsed {
      titleAccessory
        .padding(.bottom, 4)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
    }
  }
}

extension NavigationBar where TitleAccessory == EmptyView {
  public init(
    leading: Leading,
    title: Title,
    trailing: Trailing,
    height: CGFloat? = navigationBarMinHeight
  ) {

    self.init(
      leading: leading,
      title: title,
      titleAccessory: EmptyView(),
      trailing: trailing,
      height: height ?? navigationBarMinHeight)
  }
}

private struct NavigationBarLayout: Layout {
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {

    return proposal.replacingUnspecifiedDimensions()

  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let left: LayoutSubview?
    let center: LayoutSubview
    let right: LayoutSubview?
    let isCollapsed: Bool = bounds.height <= navigationBarMinHeight

    switch subviews.count {
    case 3:
      left = subviews[0]
      center = subviews[1]
      right = subviews[2]

    case 2 where subviews[0].priority == 2:
      left = subviews[0]
      center = subviews[1]
      right = nil

    case 1:
      left = nil
      center = subviews[0]
      right = nil

    default:
      return
    }

    let leadingWidth = left?.dimensions(in: proposal).width ?? 0
    let trailingWidth = right?.dimensions(in: proposal).width ?? 0

    let widthMax = bounds.width - trailingWidth - leadingWidth

    let paddingCentered = max(trailingWidth, leadingWidth)
    let widthCentered = bounds.width - 2 * paddingCentered
    let centerWidth = center.dimensions(in: .init(width: widthMax, height: nil)).width

    left?.place(
      at: .init(x: bounds.minX, y: bounds.minY + navigationBarMinHeight / 2), anchor: .leading,
      proposal: .init(width: leadingWidth, height: navigationBarMinHeight))

    if !isCollapsed || centerWidth <= widthCentered {
      center.place(
        at: .init(x: bounds.midX, y: bounds.minY + bounds.height), anchor: .bottom,
        proposal: ProposedViewSize(
          width: centerWidth, height: isCollapsed ? navigationBarMinHeight : nil))

    } else {
      center.place(
        at: .init(x: bounds.minX + leadingWidth, y: bounds.midY), anchor: .leading,
        proposal: ProposedViewSize(
          width: centerWidth, height: isCollapsed ? navigationBarMinHeight : nil))
    }

    right?.place(
      at: .init(x: bounds.width + bounds.minX, y: bounds.minY + navigationBarMinHeight / 2),
      anchor: .trailing, proposal: .init(width: trailingWidth, height: navigationBarMinHeight))
  }
}

struct NavigationBar_Previews: PreviewProvider {
  static var previews: some View {
    NavigationBar(
      leading: BackButton {},
      title: Text("Title"),
      trailing: EmptyView()
    )
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Default Height - small title")

    NavigationBar(
      leading: BackButton {},
      title: Text("Title Title Title Title Title Title Title Title").lineLimit(1),
      trailing: EmptyView()
    )
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Default Height - large title")

    NavigationBar(
      leading: BackButton {},
      title: Text("Title Title Title Title Title Title Title Title").lineLimit(1),
      trailing: Button("Edit", action: {})
    )
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Default Height - large title with leading and trailing")

    VStack {
      NavigationBar(
        leading: BackButton {},
        title: Text(
          "Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title"
        ),
        titleAccessory: Image(systemName: "square.and.pencil.circle")
          .resizable()
          .frame(width: 64, height: 64),
        trailing: Button("Edit", action: {})
      )
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Default Height - large title with leading and trailing")

      Divider()
      NavigationBar(
        leading: BackButton {},
        title: Text(
          "Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title"
        ),
        titleAccessory: Image(systemName: "square.and.pencil.circle")
          .resizable()
          .frame(width: 64, height: 64),
        trailing: Button("Edit", action: {}),
        height: 150)

    }
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Custom height - large title with accessory")
  }
}
