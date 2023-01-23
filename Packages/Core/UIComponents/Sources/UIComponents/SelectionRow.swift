import SwiftUI
import UIDelight
import DesignSystem

public struct SelectionRow<Content: View>: View {
    let content: Content
    let isSelected: Bool

    let spacing: CGFloat?
    let size: CGFloat

    private var selectedAsset: ImageAsset {
        Asset.checkboxSelected
    }

    private var unselectedAsset: ImageAsset {
        Asset.checkboxUnselected
    }

    public init(isSelected: Bool,
                spacing: CGFloat? = nil,
                size: CGFloat = 24,
                @ViewBuilder content: () -> Content) {
        self.content = content()
        self.spacing = spacing
        self.isSelected = isSelected
        self.size = size
    }

    public var body: some View {
        HStack(spacing: spacing) {
            image
                .frame(width: size, height: size)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeInOut, value: isSelected)
    }

    @ViewBuilder
    var image: some View {
        if isSelected {
            Image(asset: selectedAsset)
                .resizable()
                .transition(.selectAnyTransition)
        } else {
            Image(asset: unselectedAsset)
                .resizable()
        }
    }
}

extension AnyTransition {
    static var selectAnyTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .scale(scale: 1.6),
                                 removal: .scale(scale: 0.5))
            .combined(with: .opacity)
    }
}

struct SelectionRow_Previews: PreviewProvider {
    struct TestView: View {
        @State
        var isSelected: Bool
        let text: String

        var body: some View {
            SelectionRow(isSelected: isSelected) {
                Text(text)
            }
            .onTapWithFeedback {
                isSelected.toggle()
            }
            .padding()
            .background(.ds.background.default)
        }
    }

    static var previews: some View {
        MultiContextPreview {
            TestView(isSelected: false, text: "The Spice must Flow")
            TestView(isSelected: true, text: "Fear is the mind-killer")
        }.previewLayout(.sizeThatFits)
    }
}
