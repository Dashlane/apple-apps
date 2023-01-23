import Foundation
import Combine

enum VaultViewScenes {
    case credentialsList(CredentialsListViewModel)
    case emptyVault(EmptyVaultViewModelProtocol)
}

enum VaultSubView {
    case credentialDetails(CredentialDetailsViewModel)
}
