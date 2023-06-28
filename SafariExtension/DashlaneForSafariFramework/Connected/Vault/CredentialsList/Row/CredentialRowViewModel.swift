import Foundation
import CorePersonalData
import Combine
import CoreSession
import CoreUserTracking
import Cocoa
import TOTPGenerator
import DashlaneAppKit
import CoreSettings
import VaultKit
import DashTypes
import CoreFeature
import CorePremium

class CredentialRowViewModel: ObservableObject, SessionServicesInjecting {

    let item: Credential
    let iconViewModel: VaultItemIconViewModel
    let activityReporter: ActivityReporterProtocol
    let vaultItemsService: VaultItemsServiceProtocol
    let featureService: FeatureServiceProtocol
    let space: UserSpace?
    let sharingPermissionProvider: SharedVaultHandling
    let pasteboardService: PasteboardService

    let actionsPublisher = PassthroughSubject<CredentialRowAction, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    var id: String {
        item.id.rawValue
    }

    var copyActions: [CopyCredentialAction] {
        var actions = [CopyCredentialAction]()
        
        if !item.email.isEmpty {
            actions.append(.email)
        }
        
        if !item.login.isEmpty {
            actions.append(.login)
        }
        
        if !item.secondaryLogin.isEmpty {
            actions.append(.secondaryLogin)
        }
        
        if !item.password.isEmpty {
            actions.append(.password(limited: !sharingPermissionProvider.canCopyProperties(in: item)))
        }
        
        if item.otpURL != nil {
            actions.append(.oneTimePassword)
        }
        
        return actions
    }
    
    let canOpenWebsite: Bool
    
    init(item: Credential,
         sharingService: SharedVaultHandling,
         teamSpacesService: TeamSpacesService,
         featureService: FeatureServiceProtocol,
         vaultItemsService: VaultItemsServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         pasteboardService: PasteboardService,
         iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel) {
        self.item = item
        self.iconViewModel = iconViewModelProvider(item)
        self.space = teamSpacesService.displayedUserSpace(for: item)
        self.vaultItemsService = vaultItemsService
        self.sharingPermissionProvider = sharingService
        self.featureService = featureService
        self.activityReporter = activityReporter
        self.pasteboardService = pasteboardService
        canOpenWebsite = item.openableURL != nil
        
        actionsPublisher
            .sink(receiveValue: { [weak self] action in
                switch action {
                case let .copy(copyAction):
                    self?.performCopy(copyAction)
                case .goToWebsite:
                    self?.goToWebsite()
                }
            })
            .store(in: &cancellables)
    }
   
    func performCopy(_ action: CopyCredentialAction) {
        switch action {
        case .email:
            pasteboardService.set(item.email)
        case .login:
            pasteboardService.set(item.login)
        case .secondaryLogin:
            pasteboardService.set(item.secondaryLogin)
        case .password:
            guard sharingPermissionProvider.canCopyProperties(in: item) else {
                assertionFailure("Should not allow users to copy when it's a limited credential.")
                return
            }
            pasteboardService.set(item.password)
        case .oneTimePassword:
            guard let url = item.otpURL, let otpInfo = try? OTPConfiguration(otpURL: url) else {
                return
            }
            let code = TOTPGenerator.generate(with: otpInfo.type, for: Date(), digits: otpInfo.digits, algorithm: otpInfo.algorithm, secret: otpInfo.secret)
            pasteboardService.set(code)
        case .note:
            pasteboardService.set(item.note)
        }
    }
    
    func goToWebsite() {
        guard let openable = item.openableURL else { return }
        NSWorkspace.shared.openInSafari(openable)
    }
}

extension Credential {
    var openableURL: URL? {
        url?.openableURL 
    }
}

extension VaultItemIconViewModel: SessionServicesInjecting { }

extension CredentialRowViewModel {
    static func mock(credential: Credential) -> CredentialRowViewModel {
        let container = MockServicesContainer()
        
        return CredentialRowViewModel(item: credential,
                                      sharingService: SharedVaultHandlerMock(),
                                      teamSpacesService: .mock(),
                                      featureService: .mock(),
                                      vaultItemsService: container.vaultItemsService,
                                      activityReporter: .fake,
                                      pasteboardService: PasteboardService(userSettings: UserSettings(internalStore: .mock())),
                                      iconViewModelProvider: { VaultItemIconViewModel.mock(item: $0) })
    }
}
