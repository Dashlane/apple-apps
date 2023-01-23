import SwiftUI
import CorePersonalData
import CorePasswords
import DashlaneReportKit
import DashTypes
import UIDelight
import DashlaneAppKit
import SwiftTreats
import IconLibrary
import UIComponents
import CoreFeature

struct CredentialDetailView: View, DismissibleDetailView {

    @ObservedObject
    var model: CredentialDetailViewModel

    @Environment(\.navigator)
    var navigator

    @State
    var code: String = ""

    @Environment(\.dismiss)
    var dismissAction

    @Environment(\.detailContainerViewSpecificDismiss)
    var dismissView

    @FeatureState(.collections)
    private var areCollectionsEnabled: Bool

    @State
    private var showLinkedDomains: Bool = false

    @State
    private var showAddedDomainsList: Bool = false

    @State
    var showPasswordGenerator: Bool = false

    @State
    var showEmailSuggestions: Bool = false

    init(model: CredentialDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            mainSection

            domainsSection

            if model.mode == .updating {
                autoLoginSubdomainSection
            }

            collectionsSection

            if model.mode == .viewing {
                passwordHealthSection
            }

            sharingSections

            if model.mode == .updating || !model.item.note.isEmpty {
                notesSection
            }
        }
        .sheet(isPresented: $model.isAdd2FAFlowPresented) {
            AddOTPFlowView(viewModel: model.makeAddOTPFlowViewModel())
        }
        .navigation(isActive: $showPasswordGenerator) {
            PasswordGeneratorView(viewModel: model.makePasswordGeneratorViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigation(isActive: $showEmailSuggestions) {
            SuggestionsDetailView(items: model.emailsSuggestions, selection: $model.item.email)
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showAddedDomainsList) {
            NavigationView { addedDomainsList(isAdditionMode: true) }
        }
        .navigation(isActive: $showLinkedDomains, destination: { addedDomainsList() })
        .modifier(AutofillDemoModifier.init(isPresented: $model.isAutoFillDemoModalShown,
                                            showAutofillDemo: self.model.showAutoFillDemo,
                                            dismiss: self.dismiss))
        .onAppear {
            if self.model.mode.isAdding {
                self.model.logger.logAddCredential(credential: self.model.item)
            }
        }
        .makeShortcuts(model: model)
        .detailContainerViewSpecificSave(.init(model.save))
    }

        var mainSection: some View {
        CredentialMainSection(
            model: model.credentialMainSectionModelFactory.make(
                service: model.service,
                code: $code,
                isAutoFillDemoModalShown: $model.isAutoFillDemoModalShown,
                isAdd2FAFlowPresented: $model.isAdd2FAFlowPresented
            ),
            showPasswordGenerator: $showPasswordGenerator,
            showEmailSuggestions: $showEmailSuggestions
        )
    }

        @ViewBuilder
    private var domainsSection: some View {
        DomainsSection(
            model: model.domainsSectionModelFactory.make(service: model.service),
            showLinkedDomains: $showLinkedDomains,
            showAddedDomainsList: $showAddedDomainsList
        )
    }

        var autoLoginSubdomainSection: some View {
        AutoLoginSubdomainSection(item: $model.item)
    }

        @ViewBuilder
    var collectionsSection: some View {
        if areCollectionsEnabled {
            CollectionsSection(model: .init(service: model.service))
        }
    }

        var passwordHealthSection: some View {
        PasswordHealthSection(model: model.passwordHealthSectionModel)
    }

        var sharingSections: some View {
        SharingDetailSection(model: model.sharingDetailSectionModelFactory
            .make(item: model.item))
    }

        var notesSection: some View {
        NotesSection(model: model.notesSectionModelFactory.make(service: model.service))
    }
}

struct AutofillDemoModifier: ViewModifier {

    let isPresented: Binding<Bool>

    let showAutofillDemo: () -> Void

    let dismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .bottomSheet(isPresented: isPresented) {
                AutoFillDemoModal { result in
                    isPresented.wrappedValue = false
                                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        switch result {
                        case .tryDemo:
                            self.showAutofillDemo()
                        case .returnHome:
                            dismiss()
                        }
                    }
                }
            }
    }
}

private extension CredentialDetailView {
    func addedDomainsList(isAdditionMode: Bool = false) -> some View {
        var addedDomains = model.addedDomains
        if isAdditionMode {
            addedDomains.append(LinkedServices.AssociatedDomain(domain: "", source: .manual))
        }
        return CredentialDomainsView(model: model.makeDomainsViewModel(from: isAdditionMode), addedDomains: addedDomains)
    }
}

 struct CredentialDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            CredentialDetailView(model: MockVaultConnectedContainer().makeCredentialDetailViewModel(item: PersonalDataMock.Credentials.amazon, mode: .viewing))
            CredentialDetailView(model: MockVaultConnectedContainer().makeCredentialDetailViewModel(item: PersonalDataMock.Credentials.amazon, mode: .adding(prefilled: false)))
            CredentialDetailView(model: MockVaultConnectedContainer().makeCredentialDetailViewModel(item: PersonalDataMock.Credentials.amazon, mode: .updating))
        }
    }
 }
