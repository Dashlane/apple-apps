import DesignSystem
import Foundation
import SwiftTreats
import UIDelight
import UIKit

extension AppCoordinator {
  func configureAppearance() {
    UINavigationBar.appearance().tintColor = .ds.text.brand.standard
    UITabBar.appearance().tintColor = .ds.text.brand.quiet
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor =
      UIColor.ds.text.brand.standard
    UITableViewCell.appearance().backgroundColor = .ds.container.agnostic.neutral.supershy
    UITableView.appearance().tableFooterView = UIView()
    UIPageControl.appearance().currentPageIndicatorTintColor =
      .ds.container.expressive.brand.catchy.idle
    UIPageControl.appearance().pageIndicatorTintColor = .ds.container.expressive.brand.quiet.idle
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.ds.background.default)
    UISegmentedControl.appearance().setTitleTextAttributes(
      [
        .font: FontScaling.scaledFont(
          font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)),
        .foregroundColor: UIColor.ds.text.neutral.standard,
      ],
      for: .selected
    )

    UISegmentedControl.appearance().setTitleTextAttributes(
      [
        .font: FontScaling.scaledFont(font: UIFont.systemFont(ofSize: UIFont.systemFontSize)),
        .foregroundColor: UIColor.ds.text.neutral.catchy,
      ],
      for: .normal
    )

    UIBarButtonItem.appearance().setTitleTextAttributes(
      [
        .foregroundColor: UIColor.ds.text.brand.standard
      ],
      for: .normal
    )

    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor =
      .ds.container.agnostic.neutral.quiet
    UIButton.appearance().tintColor = .ds.text.brand.standard
    UISwitch.appearance().onTintColor = .ds.container.expressive.brand.catchy.idle
    UITextView.appearance().linkTextAttributes = [.foregroundColor: UIColor.ds.text.brand.standard]
  }
}
