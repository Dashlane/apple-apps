import SwiftUI

enum PopoverNavigationBarStyle {
        case `default`(DefaultNavigation)
        case details(DetailsNavigation)
}

struct NavigationAction {
    let image: ImageAsset
    var action: (() -> Void) = {}
}

struct DefaultNavigation {
    let title: String
    var leadingAction: NavigationAction = .init(image: Asset.back)
    let trailingAction: NavigationAction?
}

struct DetailsNavigation {
    let thumbnail: VaultItemIconView
    let title: AnyView
    var leadingAction: NavigationAction = .init(image: Asset.back)
    let trailingAction: NavigationAction?
    let backgroundColor: Color
    var tintColor: Color = Color(asset: Asset.dashGreenCopy)
}
