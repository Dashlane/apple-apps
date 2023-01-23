import Foundation
import CorePersonalData
import Cocoa
import DashlaneAppKit
import CoreSettings
import VaultKit
import DashTypes

class CredentialDetailsViewModel: SessionServicesInjecting, ObservableObject {
    
    var credential: Credential
    let iconViewModel: VaultItemIconViewModel
    let pasteboardService: PasteboardService
    let sharingPermissionProvider: SharedVaultHandling
    let vaultItemService: VaultItemsServiceProtocol
    
    init(credential: Credential,
         iconViewModel: VaultItemIconViewModel,
         pasteboardService: PasteboardService,
         sharingService: SharedVaultHandling,
         vaultItemService: VaultItemsService) {
        self.credential = credential
        self.iconViewModel = iconViewModel
        self.pasteboardService = pasteboardService
        self.sharingPermissionProvider = sharingService
        self.vaultItemService = vaultItemService
    }
    
    func edit() {
        guard let deepLink = DeepLink.vault(.fetchAndShow(.init(rawIdentifier: credential.id.rawValue, component: .credential), useEditMode: true)).urlRepresentation else {
            assertionFailure()
            return
        }
        NSWorkspace.shared.openMainApplication(url: deepLink)
    }
    
    func copy(value: String) {
        pasteboardService.set(value)
    }
    
    func openWebsite(_ url: PersonalDataURL) {
        guard let openable = url.openableURL else { return }
        NSWorkspace.shared.openInSafari(openable)
    }
    
    func isLimited() -> Bool {
        sharingPermissionProvider.permission(for: credential) == .limited
    }
    
    func save() {
        _ = try? vaultItemService.save(credential)
    }
}

extension CredentialDetailsViewModel {
    static func mock(credential: Credential = PersonalDataMock.Credentials.github) -> CredentialDetailsViewModel {
        return CredentialDetailsViewModel(credential: credential,
                                          iconViewModel: VaultItemIconViewModel.mock(item: credential),
                                          pasteboardService: PasteboardService(userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore())),
                                          sharingService: SharedVaultHandlerMock(), vaultItemService: MockServicesContainer().vaultItemsService as! VaultItemsService)
    }
}
