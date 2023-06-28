import UIKit
import Combine
import SwiftUI

struct NavigationImageSet {
    let image: UIImage
    let selectedImage: UIImage
}

protocol TabElement {
    var title: String { get }
    var tabBarImage: NavigationImageSet { get }
    func showable(sessionServices: SessionServicesContainer) -> Bool
}

extension TabElement {

    var sidebarImage: NavigationImageSet {
        tabBarImage
    }

    func showable(sessionServices: SessionServicesContainer) -> Bool {
        true
    }
}

protocol TabFlow: View, TabElement {
    var tag: Int { get }
    var id: UUID { get }
    var badgeValue: CurrentValueSubject<String?, Never>? { get }
}

extension TabFlow {
    var viewController: UIViewController {
        UIHostingController(rootView: self)
    }

    var badgeValue: CurrentValueSubject<String?, Never>? {
        nil
    }
}
