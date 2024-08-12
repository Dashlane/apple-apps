import Combine
import Foundation
import StoreKit
import SwiftTreats

final class AppStoreProductViewer: NSObject, SKStoreProductViewControllerDelegate {

  enum Identifier: String {
    case passwordManager = "517914548"
    case authenticator = "1582978196"

    var scheme: String {
      switch self {
      case .passwordManager:
        return "dashlane:///"
      case .authenticator:
        return "dashlane-authenticator:///"
      }
    }
  }

  private let viewController = SKStoreProductViewController()
  private let identifier: Identifier

  private var isDisplayingStoreProductViewController = false

  private var dismissed: VoidCompletionBlock?
  private var cancellables = Set<AnyCancellable>()

  init(identifier: Identifier) {
    self.identifier = identifier
    super.init()
    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink {
      [weak self] _ in
      guard let url = URL(string: identifier.scheme), UIApplication.shared.canOpenURL(url) else {
        return
      }
      self?.viewController.dismiss(animated: true)
    }.store(in: &cancellables)
  }

  func prepareAppStorePage() async throws {
    guard !isDisplayingStoreProductViewController else { return }
    let parameters =
      [
        SKStoreProductParameterITunesItemIdentifier: identifier.rawValue
      ] as [String: Any]
    _ = try await viewController.loadProduct(withParameters: parameters)
  }

  func openAppStorePage(dismissed: @escaping () -> Void) {
    guard !isDisplayingStoreProductViewController else { return }
    isDisplayingStoreProductViewController = true
    viewController.delegate = self
    self.dismissed = dismissed
    guard let scene = UIApplication.shared.keyWindowScene,
      let rootController = scene.keyWindow?.rootViewController
    else {
      assertionFailure("Could not access the window")
      return
    }

    guard
      rootController.presentedViewController == nil
        || rootController.presentedViewController!.isBeingDismissed
    else {
      assertionFailure("We should dismiss all modals first")
      return
    }
    rootController.present(viewController, animated: true, completion: nil)
  }

  func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    isDisplayingStoreProductViewController = false
    dismissed?()
  }
}
