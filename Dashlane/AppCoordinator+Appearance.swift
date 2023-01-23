import Foundation
import UIDelight
import SwiftTreats
import DesignSystem
import UIKit

extension AppCoordinator {
    func configureAppearance() {
        UITabBar.appearance().tintColor = .ds.text.brand.quiet
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = FiberAsset.accentColor.color
        UITableViewCell.appearance().backgroundColor = FiberAsset.cellBackground.color
        UITableView.appearance().tableFooterView = UIView()
        UIPageControl.appearance().currentPageIndicatorTintColor = .ds.container.expressive.neutral.catchy.idle
        UIPageControl.appearance().pageIndicatorTintColor = .ds.container.expressive.neutral.quiet.idle
        UISegmentedControl.appearance().selectedSegmentTintColor = FiberAsset.mainBackground.color
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .font: FontScaling.scaledFont(font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)),
                .foregroundColor: UIColor.ds.text.neutral.standard
            ],
            for: .selected
        )

        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .font: FontScaling.scaledFont(font: UIFont.systemFont(ofSize: UIFont.systemFontSize)),
                .foregroundColor: FiberAsset.mainCopy.color
            ],
            for: .normal
        )

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .ds.container.agnostic.neutral.quiet

                if Device.isMac {
            UIButton.appearance().tintColor = .ds.text.brand.standard
            UISwitch.appearance().onTintColor = FiberAsset.switchDefaultTint.color
            UINavigationBar.appearance().tintColor = .ds.text.brand.standard
            UITextView.appearance().linkTextAttributes = [.foregroundColor: UIColor.ds.text.brand.standard]
        }
    }
}
