import Foundation
import DashTypes
import SwiftTreats

public enum AccountCreationMethodAvailibility {
    case sso(SSOLoginInfo)
    case masterpassword

    init?(isLoginAvailable: Bool, shouldRegisterViaSSO: Bool, serviceProviderURL: String?, isNitroProvider: Bool, context: LoginContext?) {
        guard isLoginAvailable else { return nil }

        if shouldRegisterViaSSO, let serviceProviderURL = serviceProviderURL {
            if let context = context {
                self = .sso(SSOLoginInfo(serviceProviderURL: "\(serviceProviderURL)?redirect=\(context.origin.rawValue)&frag=true", isNitroProvider: isNitroProvider))
                return
            }
            self = .sso(SSOLoginInfo(serviceProviderURL: serviceProviderURL, isNitroProvider: isNitroProvider))
        } else {
            self = .masterpassword
        }
    }
}

public struct AccountCreationHandler {
    let accountService: AccountAPIClientProtocol

	public init(apiClient: DeprecatedCustomAPIClient) {
        self.init(AccountAPIClient(apiClient: apiClient))
    }

    internal init(_ accountService: AccountAPIClientProtocol) {
        self.accountService = accountService
    }

    public func accountCreationMethodAvailibility(for login: Login, context: LoginContext? = nil, completion: @escaping CompletionBlock<(AccountCreationMethodAvailibility?), Error>) {
        self.accountService.verifyExistence(of: login) { response in
            switch response {
            case let .success(accountInfo):
                let accountCreationMethodAvailibility = AccountCreationMethodAvailibility(isLoginAvailable: !accountInfo.isAccountRegistered,
                                                                                          shouldRegisterViaSSO: accountInfo.sso,
                                                                                          serviceProviderURL: accountInfo.ssoServiceProviderUrl, isNitroProvider: accountInfo.ssoIsNitroProvider ?? false,
                                                                                          context: context)
                completion(.success(accountCreationMethodAvailibility))
            case let .failure(error):
                completion(Result.failure(error))
            }
        }
    }

    public func createAccount(with accountInfo: AccountCreationInfo, completion: @escaping CompletionBlock<AccountCreationResponse, Error>) {
        self.accountService.create(with: accountInfo, completion: completion)
    }

    public func createSSOAccount(with accountInfo: SSOAccountCreationInfos, completion: @escaping CompletionBlock<AccountCreationResponse, Error>) {
           self.accountService.createSSOUser(with: accountInfo, completion: completion)
       }

}

public struct SSOLoginInfo {
    public let serviceProviderURL: String
    public let isNitroProvider: Bool
}
