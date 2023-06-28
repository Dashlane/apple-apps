import SwiftUI
import CorePersonalData
import UIDelight
import CoreUserTracking
import UIComponents
import DesignSystem
import PremiumKit
import VaultKit
import SwiftTreats
import AutofillKit

struct CredentialListView: View {
    @StateObject
    var model: CredentialListViewModel
    
    var body: some View {
        StepBasedNavigationView(steps: $model.steps) { step in
            switch step {
            case .list:
                list
            case let .addCredential(model):
                AddCredentialView(model: model)
            case let .paywall(model):
                PaywallView(model: model, shouldDisplayCloseButton: false, action: { self.model.handlePaywallViewAction($0) })
            }
        }
        .accentColor(.ds.text.brand.standard)
        .linkingViewContainer(isPresented: $model.displayLinkingView, view: {
            if let credentialLinkingViewModel = model.makeCredentialLinkingViewModel() {
                CredentialLinkingView(model: credentialLinkingViewModel)
            }
        })
    }

    @ViewBuilder
    var list: some View {
        ExtensionSearchView(model: model.searchViewModel,
                            addAction: { model.addAction() },
                            closeAction: { model.cancel() },
                            select: { model.select($0, origin: $1) }) {
            VStack(spacing: 0) {
                if !model.isReady {
                    ProgressViewBox()
                        .frame(maxWidth: .infinity)
                } else if model.sections.isEmpty {
                    ListPlaceholder(category: .credentials,
                                    accessory: addCredentialsPlaceholderButton.eraseToAnyView())
                    .frame(maxWidth: .infinity)
                    .background(Color(asset: FiberAsset.systemBackground))
                } else {
                    VStack(spacing: 0) {
                        ProgressView()
                            .tint(.ds.text.brand.standard)
                            .padding(.vertical, 10)
                            .hidden(!model.isSyncing)
                        listWithSuggestedItems
                    }
                }
            }
        }
                            .animation(.easeInOut, value: model.isReady)
                            .animation(.easeInOut, value: model.isSyncing)
                            .navigationTitle(L10n.Localizable.tachyonCredentialsListTitle)
                            .onAppear(perform: { model.onAppear() })
    }

    var addCredentialsPlaceholderButton: some View {
        Button(action: { self.model.addAction() }, title: ItemCategory.credentials.placeholderCtaTitle)
            .foregroundColor(.ds.text.brand.standard)
    }

    var listWithSuggestedItems: some View {
        ItemsList(sections: model.sections) { row in
            CredentialRowView(model: CredentialRowViewModel(item: row.vaultItem,
                                                            domainLibrary: self.model.domainIconLibrary)) {
                self.model.select(row.vaultItem, origin: row.isSuggestedItem ? .suggestedItems : .regularList)
            }
        }
        .indexed()
        .vaultItemsListHeader(addCredentialHeader)
        .id(model.isSyncing)
    }

    private var addCredentialHeader: some View {
        AddCredentialRowView(select: { model.addAction() })
            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 10))
    }
}

struct AddCredentialRowView: View {

    let select: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            main
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(Color(asset: FiberAsset.systemBackground))
    }

    private var main: some View {
        HStack(spacing: 16) {
            Image(asset: FiberAsset.addNewPassword)
            Button(L10n.Localizable.addNewPassword, action: select)
                .foregroundColor(.ds.text.brand.standard)
        }
        .padding(.vertical, 5)
        .onTapWithFeedback(perform: select)
    }
}

private extension View {

    @ViewBuilder
    func linkingViewContainer<V: View>(isPresented: Binding<Bool>, @ViewBuilder view: @escaping () -> V) -> some View {
        if Device.isMac {
                        self.fullScreenCover(isPresented: isPresented, content: { view() })
        } else {
            self.bottomSheet(isPresented: isPresented, detents: [.large], content: { view() })
        }
    }
}
