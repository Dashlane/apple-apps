import SwiftUI

public struct GravityAreaVStack<Top: View, Center: View, Bottom: View>: View {
    private let top: Top
    private let center: Center
    private let bottom: Bottom
    private let spacing: CGFloat?
    private let alignment: HorizontalAlignment

    public init(top: Top, center: Center, bottom: Bottom, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.top = top
        self.center = center
        self.bottom = bottom
        self.spacing = spacing
        self.alignment = alignment
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            top
                .frame(maxHeight: .infinity,
                       alignment: .top)
            center
                .frame(alignment: .center)

            bottom
                .frame(maxHeight: .infinity,
                       alignment: .bottom)

        }
    }
}

extension GravityAreaVStack where Bottom == Spacer {
    public init(top: Top, center: Center, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.init(top: top, center: center, bottom: Spacer(), alignment: alignment, spacing: spacing)
    }
}

extension GravityAreaVStack where Top == Spacer {
    public init(center: Center, bottom: Bottom, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.init(top: Spacer(), center: center, bottom: bottom, spacing: spacing)
    }
}

extension GravityAreaVStack where Center == Spacer {
    public init(top: Top, bottom: Bottom, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.init(top: top, center: Spacer(), bottom: bottom, alignment: alignment, spacing: spacing)
    }
}

struct GravityAreaVStack_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GravityAreaVStack(top: Rectangle()
                    .fill(Color.red)
                    .frame(height: 50),
                                  center:
                    Circle().frame(height: 90),
                                  bottom:
                    Rectangle().fill(Color.blue).frame(height: 120))
            GravityAreaVStack(top: Rectangle()
                    .fill(Color.red)
                    .frame(height: 150),
                                  center:
                    Circle().frame(height: 90),
                                  bottom:
                    Rectangle().fill(Color.blue).frame(height: 520))
        }

    }
}
