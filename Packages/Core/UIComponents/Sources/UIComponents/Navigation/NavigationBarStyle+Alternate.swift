import DesignSystem
import Foundation
import UIDelight
import UIKit

extension UIDelight.NavigationBarStyle {
  public static var alternate: UIDelight.NavigationBarStyle {
    return .init(tintColor: .ds.text.neutral.catchy, backgroundColor: .ds.background.alternate)
  }
}
