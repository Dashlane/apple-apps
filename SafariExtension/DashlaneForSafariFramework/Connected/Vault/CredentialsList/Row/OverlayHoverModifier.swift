import Foundation
import SwiftUI
import UIDelight

struct OverlayHoverModifier: ViewModifier {


    var buttonHover: ButtonHovered?
    var hoverType: ButtonHovered
    var width: CGFloat

    init(buttonHover: ButtonHovered?, hoverType: ButtonHovered, width: CGFloat = 75) {
        self.buttonHover = buttonHover
        self.hoverType = hoverType
        self.width = width
    }

     func body(content: Content) -> some View {
        content
            .overlay(buttonHover == hoverType ? getOverlay : nil, alignment: .leading)
    }

    @ViewBuilder
    var getOverlay: some View {
        BubbleShape(direction: .right)
            .foregroundColor(Color(asset: Asset.tooltipBackground))
            .frame(width: width-5, height: 30)
            .frame(alignment: .leading)
            .offset(x:-width)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(
                Text(hoverType.text)
                    .font(Typography.caption)
                    .offset(x:-width)
            )
            .foregroundColor(Color.black)
    }
}

extension View {
    func overlayHover(buttonHover: ButtonHovered?, hoverType: ButtonHovered, width: CGFloat = 75) -> some View {
        self.modifier(OverlayHoverModifier(buttonHover: buttonHover, hoverType: hoverType, width: width))
    }
}


