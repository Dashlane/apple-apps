import CoreLocalization
import CorePersonalData
import DesignSystem
import IconLibrary
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct AddPrefilledCredentialView: View {
  @ObservedObject
  var model: AddPrefilledCredentialViewModel

  @State
  private var isActive: Bool = false

  @FocusState
  private var isSearchFieldFocused: Bool

  @Environment(\.dismiss)
  private var dismiss

  @Environment(\.detailContainerViewSpecificDismiss)
  private var dismissView

  @Environment(\.prefilledCredentialViewSpecificBackButton)
  var specificBackButton

  @ScaledMetric private var searchBarCornerRadius: CGFloat = 10

  @ViewBuilder
  var backButton: some View {
    if let dismissView {
      NavigationBarButton(
        specificBackButton == .back
          ? CoreLocalization.L10n.Core.kwBack : CoreLocalization.L10n.Core.cancel
      ) {
        dismissView()
      }
    } else {
      BackButton {
        dismiss()
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
    .background(.ds.background.alternate.ignoresSafeArea(edges: .vertical))
    .edgesIgnoringSafeArea(.bottom)
    .frame(maxWidth: .infinity)
    .navigationBarBackButtonHidden(true)
    .navigationTitle(CoreLocalization.L10n.Core.kwadddatakwAuthentifiantIOS)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        backButton
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationBarButton(CoreLocalization.L10n.Core.kwNext, action: model.validate)
      }
    }
    .reportPageAppearance(.itemCredentialCreateSelectWebsite)
    .onAppear {
      self.isSearchFieldFocused = true
    }
  }

  private var searchBar: some View {
    DS.TextField(
      L10n.Localizable.kwPadFindAppNameOrUrlOnboarding,
      text: $model.searchCriteria
    )
    .style(intensity: .supershy)
    .focused($isSearchFieldFocused)
    .submitLabel(.search)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()
    .fiberAccessibilityAddTraits(.isSearchField)
    .padding(.horizontal, 16)
    .padding(.top, 16)
    .padding(.bottom, 8)
  }

  var onboarding: some View {
    ScrollView {
      VStack(spacing: 40) {
        Text(L10n.Localizable.kwPadOrSelectAServiceOnboarding)
          .font(DashlaneFont.custom(20, .regular).font)
          .foregroundColor(.ds.text.neutral.catchy)
          .fixedSize(horizontal: false, vertical: true)
          .fiberAccessibilityHint(
            Text(L10n.Localizable.accessibilityNewCredentialListCount(model.onboardingItems.count)))
        prefilledCredentials
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
      .padding(.top, 20)
    }
    .scrollDismissesKeyboard(.immediately)
    .padding(.horizontal, 20)
  }

  @ViewBuilder
  var prefilledCredentials: some View {
    let gridItem = GridItem(.fixed(70), spacing: 24, alignment: .top)

    LazyVGrid(columns: [gridItem, gridItem, gridItem], spacing: 18) {
      ForEach(Array(model.onboardingItems.enumerated()), id: \.offset) { index, credential in
        Button(
          action: {
            self.model.didChooseCredential(credential, true)
          },
          label: {
            PrefilledCredentialView(
              title: credential.title,
              credential: credential,
              iconViewModel: self.model.makeIconViewModel(for: credential))
          }
        )
        .fiberAccessibilityLabel(
          Text(
            L10n.Localizable.kwPadOrSelectAServiceOnboardingElementAccessibility(
              credential.title, index + 1, model.onboardingItems.count))
        )
        .foregroundColor(.ds.text.neutral.standard)
      }
    }
  }

  var searchResult: some View {
    List(model.websites, id: \.self) { website in
      Text(website).onTapWithFeedback {
        self.model.select(website: website)
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .onAppear {
      UICollectionView.appearance().contentInset.top = -16
    }
    .onDisappear {
      UICollectionView.appearance().contentInset.top = 0
    }
    .scrollContentBackground(.hidden)
  }
}

#Preview {
  AddPrefilledCredentialView(model: .mock)
}
