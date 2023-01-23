import Foundation
import Combine
import DashTypes
import SwiftTreats
import CoreNetworking
import CorePersonalData
import DashlaneAppKit
import CorePremium
import CoreSettings
import CoreFeature

public struct VPNCredentialsResponse: Decodable {
    var password: String
}

public struct VPNCredentialsInput: Encodable {
    var email: String
}

enum VPNServiceError: String, Error {
    case userDoesntHaveVPNCapability = "USER_DOESNT_HAVE_VPN_CAPABILITY"
    case userAlreadyHasAnAccount = "USER_ALREADY_HAS_AN_ACCOUNT"
    case userAlreadyHasAnAccountForProvider = "USER_ALREADY_HAS_AN_ACCOUNT_FOR_PROVIDER"
    case userAlreadyHasActiveVPNSubscription = "USER_ALREADY_HAVE_ACTIVE_VPN_SUBSCRIPTION"
}

class VPNService: Mockable {
    private let apiClient: DeprecatedCustomAPIClient
    private let capabilityService: CapabilityServiceProtocol
    private let featureService: FeatureServiceProtocol
    private let premiumService: PremiumService
    private let vaultItemsService: VaultItemsService
    private let userSettings: UserSettings
    private let usageLogService: UsageLogService

    static let vpnCredentialTitle = "VPN Hotspot Shield"
    static let vpnCredentialURL = URL(string: "_")!

    #if targetEnvironment(macCatalyst)
    static let vpnExternalAppId = 771076721
    #else
    static let vpnExternalAppId = 443369807
    #endif

    init(networkEngine: DeprecatedCustomAPIClient,
         capabilityService: CapabilityServiceProtocol,
         featureService: FeatureServiceProtocol,
         premiumService: PremiumService,
         vaultItemsService: VaultItemsService,
         userSettings: UserSettings,
         usageLogService: UsageLogService) {
        self.apiClient = networkEngine
        self.capabilityService = capabilityService
        self.featureService = featureService
        self.premiumService = premiumService
        self.vaultItemsService = vaultItemsService
        self.userSettings = userSettings
        self.usageLogService = usageLogService
    }

        public var isAvailable: Bool {
        if case .available = capabilityService.state(of: .secureWiFi) {
            return true
        }
        return false
    }

    public var capabilityIsEnabled: Bool {
        return premiumService.capability(for: \.secureWiFi).enabled
    }

    public var reasonOfUnavailability: SecureWifiUnavailableReason? {
        return premiumService.capability(for: \.secureWiFi).info?.reason
    }

    public func activateEmail(_ email: String, completion: @escaping CompletionBlock<Void, Error>) {
        getCredentials(for: email) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let response):
                    self.handleSuccessActivation(for: email, andPassword: response.password)
                completion(.success)
            }
        }
    }
}

private extension VPNService {
    func handleSuccessActivation(for email: String, andPassword password: String) {
        var credential = Credential()
        credential.email = email
        credential.password = password
        credential.title = VPNService.vpnCredentialTitle
        credential.url = PersonalDataURL(rawValue: VPNService.vpnCredentialURL.absoluteString)
        let now = Date()
        credential.userModificationDatetime = now
        credential.passwordModificationDate = now
        _ = try? self.vaultItemsService.save(credential)
    }
}

private extension VPNService {
    func getCredentials(for email: String, completion: @escaping CompletionBlock<VPNCredentialsResponse, Error>) {
        let input = VPNCredentialsInput(email: email)

        apiClient.sendRequest(to: "/v1/vpn/GetCredentials", using: .post, input: input) { (result: Result<VPNCredentialsResponse, Error>) in
            switch result {
                case .failure(let error as APIErrorResponse):
                    guard let apiError = error.errors.last else {
                        completion(result)
                        return
                    }
                    let serviceError = VPNServiceError(rawValue: apiError.code)
                    completion(.failure(serviceError ?? apiError))
                default:
                    completion(result)
            }
        }
    }
}
