import Foundation
import DashlaneAPI
import CoreSession
import Combine
import DashTypes
import CoreNetworking
import SwiftTreats

@MainActor
public class AccountVerificationFlowModel: ObservableObject, LoginKitServicesInjecting {

    @Published
    var verificationMethod: VerificationMethod

    private let login: String
    private let accountVerificationService: AccountVerificationService
    private let tokenVerificationViewModelFactory: TokenVerificationViewModel.Factory
    private let debugTokenPublisher: AnyPublisher<String, Never>?
    private let totpVerificationViewModelFactory: TOTPVerificationViewModel.Factory
    private let nonAuthenticatedUKIBasedWebService: LegacyWebService
    private let completion: @MainActor (Result<(AuthTicket, Bool), Error>) -> Void

    public init(login: String,
                verificationMethod: VerificationMethod,
                appAPIClient: AppAPIClient,
                deviceInfo: DeviceInfo,
                debugTokenPublisher: AnyPublisher<String, Never>? = nil,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                tokenVerificationViewModelFactory: TokenVerificationViewModel.Factory,
                totpVerificationViewModelFactory: TOTPVerificationViewModel.Factory,
                completion: @escaping @MainActor (Result<(AuthTicket, Bool), Error>) -> Void) {
        self.login = login
        self.verificationMethod = verificationMethod
        self.debugTokenPublisher = debugTokenPublisher
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.totpVerificationViewModelFactory = totpVerificationViewModelFactory
        self.tokenVerificationViewModelFactory = tokenVerificationViewModelFactory
        self.completion = completion
        self.accountVerificationService = AccountVerificationService(login: login, appAPIClient: appAPIClient, deviceInfo: deviceInfo)
    }

    func makeTokenVerificationViewModel() -> TokenVerificationViewModel {
        tokenVerificationViewModelFactory.make(tokenPublisher: debugTokenPublisher, accountVerificationService: accountVerificationService) { [weak self] result in
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
        totpVerificationViewModelFactory.make(accountVerificationService: accountVerificationService, recover2faWebService: Recover2FAWebService(webService: nonAuthenticatedUKIBasedWebService, login: Login(login)), pushType: verificationMethod.pushType) {[weak self] result in
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
        AuthenticatorPushVerificationViewModel(login: Login(accountVerificationService.login),
                                               accountVerificationService: accountVerificationService) { [weak self] result in
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
        AccountVerificationFlowModel(login: "", verificationMethod: verificationMethod, appAPIClient: .fake, deviceInfo: .mock, nonAuthenticatedUKIBasedWebService: LegacyWebServiceMock(response: ""), tokenVerificationViewModelFactory: .init({ _, _, _  in
            TokenVerificationViewModel.mock
        }), totpVerificationViewModelFactory: .init({ _, _, _, _ in
            TOTPVerificationViewModel.mock
        }), completion: {_ in})
    }
}
