import SwiftUI

struct VaultView: View {
    
    let viewModel: VaultViewModel
    
    @Environment(\.popoverNavigator)
    var navigator

    var body: some View {
        Group {
            switch viewModel.scene {
            case let .credentialsList(listModel):
                CredentialsListView(viewModel: listModel)
            case let .emptyVault(viewModel):
                EmptyVaultView(viewModel: viewModel)
            }
        }
        .navigator(navigator)
    }

    private func push(_ vaultSubView: VaultSubView) {
        guard let navigator = navigator else {
            assertionFailure()
            return
        }
        switch vaultSubView {
        case let .credentialDetails(viewModel):
            navigator.push(CredentialDetailsView(viewModel: viewModel))
        }
    }
}
