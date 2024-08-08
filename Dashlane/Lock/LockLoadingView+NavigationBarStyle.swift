import Foundation
import LoginKit
import UIComponents

extension LockLoadingView: NavigationBarStyleProvider {
  public var navigationBarStyle: UIComponents.NavigationBarStyle {
    return .transparent()
  }
}
