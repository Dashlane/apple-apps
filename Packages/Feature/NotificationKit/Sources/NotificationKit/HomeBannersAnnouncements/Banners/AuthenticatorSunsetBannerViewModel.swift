import CoreKeychain
import CoreSettings
import Foundation

@MainActor
public class AuthenticatorSunsetBannerViewModel: ObservableObject {
  public enum Action {
    case showAuthenticatorSunsetPage
  }

  private let authenticatorPairingProvider: AuthenticatorPairingProviderProtocol
  private let userSettings: UserSettings
  private let action: (Action) -> Void

  let sunsetDate: String

  @Published
  var displayHelpCenter: Bool = false

  public init(
    authenticatorPairingProvider: AuthenticatorPairingProviderProtocol,
    userSettings: UserSettings,
    action: @escaping (Action) -> Void
  ) {
    self.authenticatorPairingProvider = authenticatorPairingProvider
    self.userSettings = userSettings
    self.action = action

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let sunsetDate = formatter.date(from: "2024/05/13 00:00") ?? Date()
    formatter.dateStyle = .medium
    self.sunsetDate = formatter.string(from: sunsetDate)
  }

  func isPairedWithAuthenticator() -> Bool {
    authenticatorPairingProvider.isPairedWithAuthenticator()
  }

  func dismiss() {
    userSettings[.hasDismissedAuthenticatorSunsetBanner] = true
  }

  func learnMore() {
    if isPairedWithAuthenticator() {
      action(.showAuthenticatorSunsetPage)
    } else {
      displayHelpCenter = true
    }
  }
}

extension AuthenticatorSunsetBannerViewModel {
  public static var mock: AuthenticatorSunsetBannerViewModel {
    .init(
      authenticatorPairingProvider: FakeAuthenticatorPairingProvider(),
      userSettings: .mock,
      action: { _ in }
    )
  }
}
