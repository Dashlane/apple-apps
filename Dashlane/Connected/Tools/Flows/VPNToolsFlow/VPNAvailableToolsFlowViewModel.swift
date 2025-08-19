import Combine
import CoreSession
import Foundation
import StoreKit
import SwiftTreats
import UserTrackingFoundation

@MainActor
class VPNAvailableToolsFlowViewModel: NSObject, ObservableObject, SessionServicesInjecting {

  enum Step {
    case root
    case accountActivation
  }

  public enum Action {
    case activateAccount
    case accountActivated
    case openApp
    case openHotspotShieldSupport
    case openDashlaneSupport
    case openVPNUsageSupport
  }

  static let hotspotshieldDeepLink = "hotspotshield://signin"

  let session: Session

  let vpnMainViewModelFactory: VPNMainViewModel.Factory
  let vpnActivationViewModelFactory: VPNActivationViewModel.Factory

  #if !os(visionOS)
    private let skStoreProductViewController = SKStoreProductViewController()
  #endif

  let actionPublisher = PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>()
  private var cancellables = Set<AnyCancellable>()
  private let activityReporter: ActivityReporterProtocol
  private var isDisplayingStoreProductViewController = false

  @Published
  var steps: [Step] = [.root]

  init(
    session: Session,
    activityReporter: ActivityReporterProtocol,
    vpnMainViewModelFactory: VPNMainViewModel.Factory,
    vpnActivationViewModelFactory: VPNActivationViewModel.Factory
  ) {
    self.session = session
    self.activityReporter = activityReporter
    self.vpnMainViewModelFactory = vpnMainViewModelFactory
    self.vpnActivationViewModelFactory = vpnActivationViewModelFactory
    super.init()
    setup()
  }

  func setup() {
    actionPublisher.receive(on: RunLoop.main).sink { [weak self] action in
      guard let self = self else { return }
      switch action {
      case .activateAccount:
        self.steps.append(.accountActivation)
      case .accountActivated:
        self.handleAccountActivated()
      case .openApp:
        #if os(visionOS)
          break
        #else
          self.showStoreProduct()
        #endif
      case .openHotspotShieldSupport:
        UIApplication.shared.open(URL(string: "_")!)
      case .openDashlaneSupport:
        UIApplication.shared.open(URL(string: "_")!)
      case .openVPNUsageSupport:
        UIApplication.shared.open(URL(string: "_")!)
      }
    }.store(in: &cancellables)
  }
}

extension VPNAvailableToolsFlowViewModel {

  fileprivate func handleAccountActivated() {
    self.steps.removeLast()
    activityReporter.report(UserEvent.ActivateVpn(flowStep: .complete))
  }

  #if !os(visionOS)
    func showStoreProduct() {
      let url = URL(string: Self.hotspotshieldDeepLink)!

      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
        UIPasteboard.general.string = Self.hotspotshieldDeepLink

        if Device.is(.mac) {
          let appLink = "itms-apps://itunes.apple.com/app/id\(VPNService.vpnExternalAppId)"
          guard let appURL = URL(string: appLink), UIApplication.shared.canOpenURL(appURL) else {
            return
          }
          UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
          guard !isDisplayingStoreProductViewController else { return }

          isDisplayingStoreProductViewController = true
          let parameters = [
            SKStoreProductParameterITunesItemIdentifier: "\(VPNService.vpnExternalAppId)"
          ]
          skStoreProductViewController.loadProduct(withParameters: parameters) {
            [weak self] (loaded, _) in
            guard let self = self, loaded else { return }
            DispatchQueue.main.async {
              UIApplication.shared.keyUIWindow?.rootViewController?.present(
                self.skStoreProductViewController, animated: true, completion: nil)
            }
          }
        }
      }

      activityReporter.report(UserEvent.DownloadVpnClient())
    }
  #endif
}

#if !os(visionOS)
  extension VPNAvailableToolsFlowViewModel: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
      isDisplayingStoreProductViewController = false
    }
  }
#endif

extension VPNAvailableToolsFlowViewModel {
  static var mock: VPNAvailableToolsFlowViewModel {
    VPNAvailableToolsFlowViewModel(
      session: .mock,
      activityReporter: .mock,
      vpnMainViewModelFactory: .init({ _, _, _ in .mock(mode: .activationNeeded) }),
      vpnActivationViewModelFactory: .init({ _, _ in .mock() }))
  }
}
