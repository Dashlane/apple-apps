import Foundation
import UIKit

class DashlaneTabBarController: UITabBarController {

    var willAppear: (() -> Void)?
    var willDisappear: (() -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear?()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappear?()
    }
}
