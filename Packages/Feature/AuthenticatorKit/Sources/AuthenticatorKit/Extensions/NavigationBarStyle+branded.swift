#if canImport(UIKit)
  import DesignSystem
  import UIDelight
  import UIComponents

  extension UIDelight.NavigationBarStyle {
    public static var brandedBarStyle: UIDelight.NavigationBarStyle {
      .customLargeFontStyle(
        DashlaneFont.custom(26, .medium).uiFont,
        titleColor: .ds.text.neutral.catchy,
        backgroundColor: .ds.background.alternate)
    }
  }
#endif
