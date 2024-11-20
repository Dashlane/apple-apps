import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class SSOUnlockViewModel: ObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(SSOKeys)
    case cancel
    case logout
  }

  let login: Login
  let apiClient: AppAPIClient
  let nitroClient: NitroSSOAPIClient
  let deviceAccessKey: String
  let cryptoEngineProvider: CryptoEngineProvider
  let activityReporter: ActivityReporterProtocol
  let ssoLoginViewModelFactory: SSOLocalLoginViewModel.Factory
  let completion: Completion<SSOUnlockViewModel.CompletionType>

  @Published
  var ssoAuthenticationInfo: SSOAuthenticationInfo?

  @Published
  var inProgress = false

  @Published
  var errorMessage: String?

  public init(
    login: Login,
    apiClient: AppAPIClient,
    nitroClient: NitroSSOAPIClient,
    deviceAccessKey: String,
    cryptoEngineProvider: CryptoEngineProvider,
    activityReporter: ActivityReporterProtocol,
    ssoLoginViewModelFactory: SSOLocalLoginViewModel.Factory,
    completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
  ) {
    self.login = login
    self.apiClient = apiClient
    self.nitroClient = nitroClient
    self.deviceAccessKey = deviceAccessKey
    self.cryptoEngineProvider = cryptoEngineProvider
    self.activityReporter = activityReporter
    self.ssoLoginViewModelFactory = ssoLoginViewModelFactory
    self.completion = completion
  }

  func unlock() {
    errorMessage = nil
    inProgress = true
    Task {
      do {
        let ssoAuthenticationInfo = try await self.apiClient.authentication.ssoInfo(
          for: login, deviceAccessKey: deviceAccessKey)
        self.ssoAuthenticationInfo = ssoAuthenticationInfo
      } catch {
        errorMessage = L10n.errorMessage(for: error)
      }
      inProgress = false
    }
  }

  func makeSSOLoginViewModel(ssoAuthenticationInfo: SSOAuthenticationInfo) -> SSOLocalLoginViewModel
  {
    return ssoLoginViewModelFactory.make(
      deviceAccessKey: deviceAccessKey, ssoAuthenticationInfo: ssoAuthenticationInfo
    ) { result in
      self.ssoAuthenticationInfo = nil
      switch result {
      case let .success(type):
        switch type {
        case .cancel:
          self.completion(.success(.cancel))
        case let .completed(ssoKeys):
          self.completion(.success(.completed(ssoKeys)))
        }
      case let .failure(error):
        self.completion(.failure(error))
      }
    }
  }

  public func logOnAppear() {
    activityReporter.report(
      UserEvent.AskAuthentication(
        mode: .sso,
        reason: .unlockApp))
    activityReporter.reportPageShown(.unlock)
  }

  func logout() {
    self.completion(.success(.logout))
  }
}

extension AppAPIClient.Authentication {
  fileprivate func ssoInfo(for login: Login, deviceAccessKey: String) async throws
    -> SSOAuthenticationInfo
  {
    let response = try await getAuthenticationMethodsForLogin(
      login: login.email,
      deviceAccessKey: deviceAccessKey,
      methods: [.emailToken, .totp, .duoPush],
      profiles: [
        AuthenticationMethodsLoginProfiles(
          login: login.email,
          deviceAccessKey: deviceAccessKey
        )
      ],
      u2fSecret: nil
    )
    let loginMethod = response.verifications.loginMethod(for: login)

    guard case let .loginViaSSO(ssoAuthenticationInfo) = loginMethod else {
      throw SSOError.invalidLoginMethod
    }
    return ssoAuthenticationInfo
  }
}

private enum SSOError: Error {
  case invalidLoginMethod
}

extension SSOUnlockViewModel {
  static var mock: SSOUnlockViewModel {
    SSOUnlockViewModel(
      login: Login("_"), apiClient: .fake, nitroClient: .fake, deviceAccessKey: "deviceAccessKey",
      cryptoEngineProvider: FakeCryptoEngineProvider(), activityReporter: .mock,
      ssoLoginViewModelFactory: .init({ _, _, _ in
        .mock
      }), completion: { _ in })
  }
}
