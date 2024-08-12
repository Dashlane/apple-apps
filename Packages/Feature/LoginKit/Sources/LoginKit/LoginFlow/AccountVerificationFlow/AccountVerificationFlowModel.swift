import Combine
import CoreNetworking
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class AccountVerificationFlowModel: ObservableObject, LoginKitServicesInjecting {

  @Published
  var verificationMethod: VerificationMethod

  private let login: Login
  private let mode: Definition.Mode
  private let accountVerificationService: AccountVerificationService
  private let tokenVerificationViewModelFactory: TokenVerificationViewModel.Factory
  private let debugTokenPublisher: AnyPublisher<String, Never>?
  private let totpVerificationViewModelFactory: TOTPVerificationViewModel.Factory
  private let completion: @MainActor (Result<(AuthTicket, Bool), Error>) -> Void

  public init(
    login: Login,
    mode: Definition.Mode,
    verificationMethod: VerificationMethod,
    appAPIClient: AppAPIClient,
    deviceInfo: DeviceInfo,
    debugTokenPublisher: AnyPublisher<String, Never>? = nil,
    tokenVerificationViewModelFactory: TokenVerificationViewModel.Factory,
    totpVerificationViewModelFactory: TOTPVerificationViewModel.Factory,
    completion: @escaping @MainActor (Result<(AuthTicket, Bool), Error>) -> Void
  ) {
    self.login = login
    self.mode = mode
    self.verificationMethod = verificationMethod
    self.debugTokenPublisher = debugTokenPublisher
    self.totpVerificationViewModelFactory = totpVerificationViewModelFactory
    self.tokenVerificationViewModelFactory = tokenVerificationViewModelFactory
    self.completion = completion
    self.accountVerificationService = AccountVerificationService(
      login: login, appAPIClient: appAPIClient, deviceInfo: deviceInfo)
  }

  func makeTokenVerificationViewModel() -> TokenVerificationViewModel {
    tokenVerificationViewModelFactory.make(
      tokenPublisher: debugTokenPublisher, accountVerificationService: accountVerificationService,
      mode: mode
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .success(authTicket):
        self.completion(.success((authTicket, false)))
      case let .failure(error):
        self.completion(.failure(error))
      }
    }
  }

  func makeTOTPVerificationViewModel() -> TOTPVerificationViewModel {
    totpVerificationViewModelFactory.make(
      accountVerificationService: accountVerificationService, pushType: verificationMethod.pushType
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .success((authTicket, isBackupCode)):
        self.completion(.success((authTicket, isBackupCode)))
      case let .failure(error):
        self.completion(.failure(error))
      }
    }
  }

  func makeAuthenticatorPushViewModel() -> AuthenticatorPushVerificationViewModel {
    AuthenticatorPushVerificationViewModel(
      login: Login(accountVerificationService.login),
      accountVerificationService: accountVerificationService
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .success(authTicket):
        self.completion(.success((authTicket, false)))
      case .error(let error):
        self.completion(.failure(error))
      case .token:
        self.verificationMethod = .emailToken
      }
    }
  }

}

extension AccountVerificationFlowModel {
  static func mock(verificationMethod: VerificationMethod) -> AccountVerificationFlowModel {
    AccountVerificationFlowModel(
      login: "", mode: .masterPassword, verificationMethod: verificationMethod, appAPIClient: .fake,
      deviceInfo: .mock,
      tokenVerificationViewModelFactory: .init({ _, _, _, _ in
        TokenVerificationViewModel.mock
      }),
      totpVerificationViewModelFactory: .init({ _, _, _ in
        TOTPVerificationViewModel.mock
      }), completion: { _ in })
  }
}
