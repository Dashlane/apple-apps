import Foundation
import SwiftUI
import UIKit

extension VaultFlowViewModel: TabCoordinator {

    var title: String {
        mode.title
    }

    var tabBarImage: NavigationImageSet {
        mode.tabBarSet
    }

    var sidebarImage: NavigationImageSet {
        mode.sidebarImage
    }

    func start() { }
}

private extension VaultFlowViewModel.Mode {
    var title: String {
        switch self {
        case .allItems:
            return L10n.Localizable.recentTitle
        case .category(let category):
            return category.title
        }
    }

    var tabBarSet: NavigationImageSet {
        switch self {
        case .allItems:
            return NavigationImageSet(
                image: FiberAsset.tabIconRecentsOff,
                selectedImage: FiberAsset.tabIconRecentsOn
            )
        case .category(let category):
            return NavigationImageSet(
                image: category.image,
                selectedImage: category.image
            )
        }
    }

    var sidebarImage: NavigationImageSet {
        switch self {
        case .allItems:
            return tabBarSet
        case .category(let category):
            return category.sidebarImage
        }
    }
}
