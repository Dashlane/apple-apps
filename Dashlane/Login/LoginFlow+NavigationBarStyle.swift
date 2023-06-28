import SwiftUI
import LoginKit
import UIComponents

extension LoginFlow: NavigationBarStyleProvider {
    public var navigationBarStyle: UIComponents.NavigationBarStyle {
        return .transparent()
    }
}
