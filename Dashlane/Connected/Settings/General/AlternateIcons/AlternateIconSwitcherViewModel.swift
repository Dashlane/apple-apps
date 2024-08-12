import Combine
import Foundation
import UIKit

final class AlternateIconSwitcherViewModel: ObservableObject {
  @Published
  var currentIcon: AppIcon

  @Published
  var icons: [AppIcon] = []

  @Published
  var showLegacyIcons: Bool = false

  let successPublisher = PassthroughSubject<Void, Never>()

  init(showPrideIcon: Bool) {
    let alternateIcons = AppIcon.alternateIcons().sorted()

    self.currentIcon =
      if let name = UIApplication.shared.alternateIconName,
        let currentIcon = alternateIcons.first(where: { $0.name == name })
      {
        currentIcon
      } else {
        .primaryIcon
      }

    if currentIcon.category == .legacy {
      showLegacyIcons = true
    }

    $showLegacyIcons.map { showLegacyIcons in
      return [.primaryIcon]
        + alternateIcons.filter({ icon in
          switch icon.category {
          case .pride where showPrideIcon:
            return true
          case .legacy where showLegacyIcons:
            return true
          case .brand, .primary:
            return true
          default:
            return false
          }
        })
    }.assign(to: &$icons)
  }

  func changeIcon(to icon: AppIcon) {
    guard icon.category != .primary else {
      UIApplication.shared.setAlternateIconName(nil)
      self.currentIcon = icon
      self.successPublisher.send()
      return
    }
    let oldIcon = self.currentIcon
    currentIcon = icon

    UIApplication.shared.setAlternateIconName(icon.name) { [weak self] error in
      if let err = error {
        print(err.localizedDescription)
        self?.currentIcon = oldIcon
      } else {
        self?.successPublisher.send()
      }
    }
  }
}
