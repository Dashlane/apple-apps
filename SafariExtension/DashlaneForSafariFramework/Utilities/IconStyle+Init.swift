import Foundation
import SwiftUI

extension IconStyle {
    init(backgroundColor: Color? = nil, sizeType: SizeType) {
        self.init(backgroundColor: backgroundColor,
                  sizeType: sizeType,
                  placeholderColor: Asset.iconPlaceholderBackground.swiftUIColor)
    }
}
