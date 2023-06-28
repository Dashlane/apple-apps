import SwiftUI
import UIDelight
import MapKit

public let navigationBarMinHeight: CGFloat = 40

public struct NavigationBar<Leading: View, Title: View, TitleAccessory: View, Trailing: View>: View {
    let leading: Leading
    let title: Title
    let titleAccessory: TitleAccessory
    let trailing: Trailing
    let height: CGFloat

    @State
    private var isCollapsed: Bool = false

    @State
    private var leadingWidth: CGFloat = 40

    @State
    private var trailingWidth: CGFloat = 40

    public init(leading: Leading,
                title: Title,
                titleAccessory: TitleAccessory,
                trailing: Trailing,
                height: CGFloat? = navigationBarMinHeight) {
        self.leading = leading
        self.title = title
        self.titleAccessory = titleAccessory
        self.trailing = trailing
        self.height = height ?? navigationBarMinHeight
    }

    public var body: some View {
        content
            .frame(height: height)
            .background(.ds.container.agnostic.neutral.standard.edgesIgnoringSafeArea(.top))
            .onPreferenceChange(CapturePreferenceKey.self) { captures in
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.isCollapsed = captures.shouldCollapse
                        self.trailingWidth = captures.trailing
                        self.leadingWidth = captures.leading
                    }
                }
            }
            .animation(.linear(duration: 0.1), value: height)
    }

    private var content: some View {
        GeometryReader { geometry in
            leadingTrailing(using: geometry)
            ZStack(alignment: .init(horizontal: .center, vertical: isCollapsed ? .top : .bottom)) {
                Color.clear 
                title(using: geometry)
            }.anchorPreference(key: CapturePreferenceKey.self, value: .bottom) { anchor in
                                CapturedValues(shouldCollapse: geometry[anchor].y <= 2 * navigationBarMinHeight)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        .font(.system(size: 17))
    }

    @ViewBuilder
    private func title(using geometry: GeometryProxy) -> some View {
        let paddingCentered = max(trailingWidth, leadingWidth)
        let widthCentered = geometry.size.width - 2*paddingCentered
        let widthMax = geometry.size.width - trailingWidth - leadingWidth

        self.title
            .font(.system(size: 17).weight(.semibold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.vertical, 8)
            .padding(.horizontal, 5)
            .background(accessory.alignmentGuide(.top, to: .bottom), alignment: .top)
            .frame(minHeight: navigationBarMinHeight)
            .frame(height: isCollapsed ? navigationBarMinHeight : nil)
            .alignmentGuide(HorizontalAlignment.center) { d in
                if !isCollapsed || d.width <= widthCentered {
                    return d[HorizontalAlignment.center]
                } else {
                    return (d.width + trailingWidth - leadingWidth) / 2
                }
            }
            .frame(maxWidth: widthMax)
    }

    @ViewBuilder
    private var accessory: some View {
        if !isCollapsed {
            titleAccessory
                .padding(.bottom, 4)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
    }

    private func leadingTrailing(using geometry: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 0) {
            self.leading
                .fixedSize()
                .anchorPreference(key: CapturePreferenceKey.self, value: .trailing, transform: { anchor in
                    CapturedValues(leading: geometry[anchor].x)
                })
            Spacer()
                .frame(maxWidth: .infinity)
            self.trailing
                .fixedSize()
                .anchorPreference(key: CapturePreferenceKey.self, value: .leading, transform: { anchor in
                    CapturedValues(trailing: geometry.size.width - geometry[anchor].x)
                })
        }
        .lineLimit(1)
        .frame(height: navigationBarMinHeight)
    }
}

public extension NavigationBar where TitleAccessory == EmptyView {
    init(leading: Leading,
         title: Title,
         trailing: Trailing,
         height: CGFloat? = navigationBarMinHeight) {

        self.init(leading: leading,
                  title: title,
                  titleAccessory: EmptyView(),
                  trailing: trailing,
                  height: height ?? navigationBarMinHeight)
    }
}

private struct CapturedValues: Equatable {
    var leading: CGFloat = 0
    var trailing: CGFloat = 0
    var shouldCollapse: Bool = true
}

private struct CapturePreferenceKey: PreferenceKey {
    static var defaultValue: CapturedValues = CapturedValues()

    static func reduce(value: inout  CapturedValues, nextValue: () -> CapturedValues) {
        let next = nextValue()
        if next.leading != 0 {
            value.leading = next.leading
        }

        if next.trailing != 0 {
            value.trailing = next.trailing
        }

        if !next.shouldCollapse {
            value.shouldCollapse = next.shouldCollapse
        }
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(leading: BackButton {},
                      title: Text("Title"),
                      trailing: Spacer())
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default Height - small title")

        NavigationBar(leading: BackButton {},
                      title: Text("Title Title Title Title Title Title Title Title")           .lineLimit(1),
                      trailing: Spacer())
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default Height - large title")

        NavigationBar(leading: BackButton {},
                      title: Text("Title Title Title Title Title Title Title Title")           .lineLimit(1),
                      trailing: Button("Edit", action: {}))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default Height - large title with leading and trailing")

        VStack {
            NavigationBar(leading: BackButton {},
                          title: Text("Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title"),
                          trailing: Button("Edit", action: {}))
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Default Height - large title with leading and trailing")

            Divider()
            NavigationBar(leading: BackButton {},
                          title: Text("Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title Title"),
                          trailing: Button("Edit", action: {}),
                          height: 150)

        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Custom height - large title")
    }
}
