import Foundation
import UIKit

final class CenteredScrollView: UIScrollView {
  override func layoutSubviews() {
    super.layoutSubviews()
    self.centerVerticallyContent()
  }

  private func centerVerticallyContent() {
    let availableHeight = self.bounds.height - contentSize.height

    guard availableHeight > 0 else { return }
    self.contentOffset.y = -(availableHeight / 2)
  }
}
