import Foundation
import UIDelight
import UIComponents

extension NavigationBarStyle {
    static var brandedBarStyle: NavigationBarStyle {
        .customLargeFontStyle(DashlaneFont.custom(26, .medium).uiFont,
                              titleColor: .ds.text.neutral.catchy,
                              backgroundColor: .ds.background.alternate)
    }
}
