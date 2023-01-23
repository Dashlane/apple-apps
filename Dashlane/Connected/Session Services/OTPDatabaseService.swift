import Foundation
import DashlaneAppKit
import TOTPGenerator
import CorePersonalData
import Combine
import DashTypes
import AuthenticatorKit
import CoreUserTracking

class OTPDatabaseService: AuthenticatorDatabaseServiceProtocol {
    let login: String?

    private let vaultItemsService: VaultItemsServiceProtocol
    private let activityReporter: ActivityReporterProtocol

    @Published
    public var codes: Set<OTPInfo> = []

    @Published
    var isLoaded = false

    var codesPublisher: AnyPublisher<Set<OTPInfo>, Never> {
        $codes.eraseToAnyPublisher()
    }

    var isLoadedPublisher: AnyPublisher<Bool, Never> {
        $isLoaded.eraseToAnyPublisher()
    }

    init(vaultItemsService: VaultItemsServiceProtocol, activityReporter: ActivityReporterProtocol) {
        self.vaultItemsService = vaultItemsService
        self.activityReporter = activityReporter
        self.login = nil
        load()
    }

    func delete(_ item: OTPInfo) throws {
        let credential = vaultItemsService.credentials.first { $0.id == item.id }

        guard var credential = credential else {
            return
        }
        credential.otpURL = nil
        try _ = vaultItemsService.save(credential)
        activityReporter.report(AnonymousEvent.RemoveTwoFactorAuthenticationFromCredential(authenticatorIssuerId: item.authenticatorIssuerId, domain: credential.hashedDomainForLogs, space: credential.userTrackingSpace))
        activityReporter.report(AnonymousEvent.UpdateCredential.init(action: .edit, domain: credential.hashedDomainForLogs, fieldList: [.otpSecret], space: credential.userTrackingSpace))
    }

    func add(_ items: [OTPInfo]) throws {
        let credentials = items.map(Credential.init)
        try _ = vaultItemsService.save(credentials)
    }

    func update(_ item: OTPInfo) throws {
        let credential = vaultItemsService.credentials.first { $0.id == item.id }

        guard var credential = credential else {
            return
        }
        credential.otpURL = item.configuration.otpURL
        try _ = vaultItemsService.save(credential)
    }

    func load() {
        vaultItemsService.$credentials.map {
            defer { self.isLoaded = true }
            return Set($0.compactMap {
                 OTPInfo(credential: $0, supportDashlane2FA: true)
            })
        }.assign(to: &$codes)
    }

}
