import DashTypes
import UIKit

final class HelpCenterSettingsViewModel: ObservableObject, SessionServicesInjecting {

  private enum Link: String {
    case howToGuide = "_"
    case troubleshooting = "_"
    case suggestFeature = "_"
    case privacyPolicy = "_"
    case termsOfService = "_"
    case deleteAccount = "_"
  }

  private enum Subaction: String {
    case getStarted
    case havingTrouble
    case feedback
    case deleteAccount
  }

  init() {
  }

  func openHowToGuide() {
    openLink(.howToGuide)
  }

  func openTroubleshooting() {
    openLink(.troubleshooting)
  }

  func openDeleteAccount() {
    openLink(.deleteAccount)
  }

  func suggestFeature() {
    openLink(.suggestFeature)
  }

  func openPrivacyPolicy() {
    openLink(.privacyPolicy)
  }

  func openTermsOfService() {
    openLink(.termsOfService)
  }

  private func openLink(_ link: Link) {
    guard let url = URL(string: link.rawValue) else { return }
    UIApplication.shared.open(url, options: [:])
  }
}

extension HelpCenterSettingsViewModel {
  static var mock: HelpCenterSettingsViewModel {
    .init()
  }
}
