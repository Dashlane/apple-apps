import LoginKit
import SwiftUI
import UIComponents

extension LoginFlow: NavigationBarStyleProvider {
  public var navigationBarStyle: UIComponents.NavigationBarStyle {
    return .transparent()
  }
}
