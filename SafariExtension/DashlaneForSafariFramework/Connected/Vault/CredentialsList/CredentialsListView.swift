import SwiftUI

struct CredentialsListView: View {
    
    @ObservedObject
    var viewModel: CredentialsListViewModel
    
    @Environment(\.popoverNavigator)
    var navigator

    @State private var hoveredCell: String?

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                SearchView(text: $viewModel.currentSearch,
                           placeholder: L10n.Localizable.searchVaultPlaceholder)
                    .frame(height: 45)
                    .padding(.horizontal)
                Divider()
                    .padding(.horizontal)
            }
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollViewReader { reader in
            if viewModel.credentials.isEmpty {
                CredentialsListNoResultView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.credentials, id: \.id) { credentialViewModel in
                            Button(action: {
                                let detailsViewModel = viewModel.makeDetailsViewModel(for: credentialViewModel)
                                navigator?.push(CredentialDetailsView(viewModel: detailsViewModel))
                            }, label: {
                                CredentialRowView(viewModel: credentialViewModel)
                                    .contentShape(Rectangle())
                            })
                            .buttonStyle(LightButtonStyle())
                            .id(credentialViewModel.id)
                            .onHover(perform: { hovering in
                                hoveredCell = hovering ? credentialViewModel.id : nil
                            })
                            .dividerAdder(isActivated: hoveredCell == credentialViewModel.id)
                        }
                    }
                }
                .onReceive(viewModel.popoverOpeningService.publisher) { popoverOpening in
                    guard popoverOpening == .afterTimeLimit else { return }
                    guard let firstCredential = viewModel.credentials.first?.id else { return }
                    reader.scrollTo(firstCredential, anchor: .top)
                }
            }
        }
    }

}

struct CredentialsListView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme(size: .popoverContent) {
            Group {
                CredentialsListView(viewModel: CredentialsListViewModel.mock(emptyList: false))
                CredentialsListView(viewModel: CredentialsListViewModel.mock(emptyList: true))
            }
        }
    }
}
