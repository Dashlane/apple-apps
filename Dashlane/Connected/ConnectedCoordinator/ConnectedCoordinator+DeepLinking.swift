import CorePremium
import Foundation
import PremiumKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIKit
import VaultKit

extension ConnectedCoordinator {
  func setupDeepLinking() {
    self.sessionServices.appServices.deepLinkingService
      .deepLinkPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        self.didReceiveDeepLink($0)
        let sessionServices = sessionServices
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          sessionServices.appServices.deepLinkingService.resetLastLink()
        }
      }.store(in: &subscriptions)
  }

  func didReceiveDeepLink(_ deepLink: DeepLink) {
    if let presentedViewController = self.window.rootViewController?.presentedViewController {
      presentedViewController.dismiss(
        animated: true,
        completion: {
          self.didReceiveDeepLink(deepLink)
        })
      return
    }

    handleDeeplink(deepLink)
  }

  private func handleDeeplink(_ deepLink: DeepLink) {
    switch deepLink {
    case .premium(let component):
      switch component {
      case .getPremium:
        showPremium(with: .list)
      case .planPurchase(let initialView):
        showPremium(with: initialView)
      }

    case .other(let otherDeeplink, let origin):
      switch otherDeeplink {
      case .m2wOnboarding:
        showM2W(origin: origin)
      default: break
      }

    case let .mplessLogin(qrcode):
      showMpLess(withQRCode: qrcode)

    default:
      break
    }
  }

  private func showM2W(origin: String? = nil) {
    guard let parentViewController = window.rootViewController?.topVisibleViewController else {
      fatalError("Can't find parentViewController")
    }

    let model = M2WFlowViewModel(initialStep: .init(origin: .init(string: origin)))
    let navigator = UINavigationController()

    let view = M2WFlowView(viewModel: model) { action in
      switch action {
      case .success:
        let settings = M2WSettings(userSettings: self.sessionServices.userSettings)
        settings.setUserHasFinishedM2W()
      default: break
      }
      navigator.dismiss(animated: true)
    }

    navigator.push(view, animated: false)
    parentViewController.present(navigator, animated: true)
  }

  func showPremium(with initialView: PlanPurchaseInitialViewRequest) {
    guard let parentViewController = window.rootViewController?.topVisibleViewController else {
      fatalError("Can't find parentViewController")
    }
    let navigator = UINavigationController()
    let planPurchaseFlowView = PurchaseFlowView(
      model: .init(
        initialView: initialView, planPurchaseServices: sessionServices.makePlanPurchaseServices())
    ) { _ in
      navigator.dismiss(animated: true)
    }
    navigator.push(planPurchaseFlowView, animated: false)
    parentViewController.present(navigator, animated: true)
  }

  func showMpLess(withQRCode qrcode: String) {
    guard let parentViewController = window.rootViewController?.topVisibleViewController else {
      fatalError("Can't find parentViewController")
    }
    let navigator = UINavigationController()
    let addNewDeviceView = AddNewDeviceAlertView(
      model: self.sessionServices.viewModelFactory.makeAddNewDeviceAlertViewModel(qrCode: qrcode))
    navigator.push(addNewDeviceView, animated: false)
    parentViewController.present(UIHostingController(rootView: addNewDeviceView), animated: true)
  }
}
