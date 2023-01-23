import SwiftUI
import CorePersonalData
import UIDelight
import DashlaneAppKit
import UIComponents
import VaultKit
import DesignSystem

struct AddPrefilledCredentialView: View {
    @ObservedObject
    var model: AddPrefilledCredentialViewModel

    @State
    private var isActive: Bool = false

    @FocusState
    private var isSearchFieldFocused: Bool

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.isPresented)
    private var isPresented

    @Environment(\.detailContainerViewSpecificDismiss)
    private var dismissView

    @Environment(\.prefilledCredentialViewSpecificBackButton)
    var specificBackButton

    @Environment(\.navigator)
    var navigator

    private var websites: [String] {
        [model.searchCriteria] + model.websites
    }

    @ViewBuilder
    var backButton: some View {
        if let dismissView {
            NavigationBarButton(specificBackButton == .back ? L10n.Localizable.kwBack : L10n.Localizable.cancel) {
                dismissView()
            }
        } else if isPresented {
            BackButton {
                dismiss()
            }
        } else {
            NavigationBarButton(L10n.Localizable.cancel) {
                self.navigator()?.dismiss()
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if model.searchCriteria.isEmpty {
                onboarding
            } else {
                searchResult
            }
        }
        .background(.ds.background.alternate)
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(L10n.Localizable.kwadddatakwAuthentifiantIOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(L10n.Localizable.kwNext, action: model.validate)
            }
        }
        .reportPageAppearance(.itemCredentialCreateSelectWebsite)
        .didAppear { 
            self.isSearchFieldFocused = true
        }
    }

    private var searchBar: some View {
        TextInput(L10n.Localizable.kwPadFindAppNameOrUrlOnboarding, text: $model.searchCriteria)
            .style(intensity: .supershy)
            .focused($isSearchFieldFocused)
            .submitLabel(.search)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .fiberAccessibilityAddTraits(.isSearchField)
            .background(.ds.container.agnostic.neutral.supershy)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 20)
    }

    var onboarding: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text(L10n.Localizable.kwPadOrSelectAServiceOnboarding)
                    .font(DashlaneFont.custom(20, .regular).font)
                    .foregroundColor(.ds.text.neutral.catchy)
                    .fixedSize(horizontal: false, vertical: true)
                    .fiberAccessibilityHint(Text(L10n.Localizable.accessibilityNewCredentialListCount(model.onboardingItems.count)))
                prefilledCredentials
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    var prefilledCredentials: some View {
        let gridItem = GridItem(.fixed(IconStyle.SizeType.prefilledCredential.size.width), spacing: 24, alignment: .top)

            LazyVGrid(columns: [gridItem, gridItem, gridItem], spacing: 18) {
                ForEach(Array(model.onboardingItems.enumerated()), id: \.offset) { index, credential in
                    Button(action: {
                        self.model.logger.selectedWebsiteUsageLog(website: credential.url?.rawValue)
                        self.model.didChooseCredential(credential, true)
                    }, label: {
                        PrefilledCredentialView(title: credential.title,
                                                credential: credential,
                                                iconViewModel: self.model.makeIconViewModel(for: credential))
                    })
                    .fiberAccessibilityLabel(Text(L10n.Localizable.kwPadOrSelectAServiceOnboardingElementAccessibility(credential.title, index + 1, model.onboardingItems.count)))
                    .foregroundColor(.ds.text.neutral.standard)
                }
            }

    }

    var searchResult: some View {
        List(websites, id: \.self) { website in
            Text(website).onTapWithFeedback {
                self.model.select(website: website)
            }
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
}

struct AddPrefilledCredentialView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AddPrefilledCredentialView(model: .mock)
        }
    }
}
