import UIKit
import Combine

struct NavigationImageSet {
    let image: ImageAsset
    let selectedImage: ImageAsset
}

enum TabElementDetail: Equatable {
    case text(String)
    case badge(BadgeConfiguration)

    var textValue: String? {
        switch self {
            case .text(let value):
                return value
            default: return nil
        }
    }

    static func == (lhs: TabElementDetail, rhs: TabElementDetail) -> Bool {
        switch (lhs, rhs) {
            case (.text(let countLhs), .text(let countRhs)):
                return countLhs == countRhs
            case (.badge(let firstBadgeConfiguration), .badge(let secondBadgeConfiguration)):
                return firstBadgeConfiguration == secondBadgeConfiguration
            default: return false
        }
    }
}

protocol TabElement {
    var title: String { get }
    var tabBarImage: NavigationImageSet { get }
    var sidebarImage: NavigationImageSet { get }
    func showable(sessionServices: SessionServicesContainer) -> Bool
    var detailInformationValue: CurrentValueSubject<TabElementDetail, Never>? { get }
}

extension TabElement {

    var sidebarImage: NavigationImageSet {
        tabBarImage
    }

    func showable(sessionServices: SessionServicesContainer) -> Bool {
        true
    }

    var detailInformationValue: CurrentValueSubject<TabElementDetail, Never>? {
        nil
    }
}

protocol TabCoordinator: Coordinator, TabElement {
    var tag: Int { get }
    var viewController: UIViewController { get }
    var id: UUID { get }
}
