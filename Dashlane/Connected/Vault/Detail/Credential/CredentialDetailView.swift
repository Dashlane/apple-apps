import AutofillKit
import CoreFeature
import CorePasswords
import CorePersonalData
import CoreTypes
import DesignSystem
import IconLibrary
import SwiftTreats
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight
import VaultKit

struct CredentialDetailView: View, DismissibleDetailView {

  @StateObject
  var model: CredentialDetailViewModel

  @Environment(\.dismiss)
  var dismissAction

  @Environment(\.detailContainerViewSpecificDismiss)
  var dismissView

  @State
  private var showLinkedDomains: Bool = false

  @State
  private var showAddedDomainsList: Bool = false

  @State
  var showPasswordGenerator: Bool = false

  @State
  var showEmailSuggestions: Bool = false

  init(model: @escaping @autoclosure () -> CredentialDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      mainSection

      domainsSection

      if model.mode == .updating {
        autoLoginSubdomainSection
      }

      if model.mode == .viewing {
        passwordHealthSection
      }

      if model.mode == .updating || !model.item.note.isEmpty {
        notesSection
      }
    } sharingSection: {
      sharingSection
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
    .sheet(isPresented: $model.isAutoFillDemoModalShown) {
      BottomSheet(
        L10n.Localizable.autofillDemoModalTitle,
        description: L10n.Localizable.autofillDemoModalSubtitle,
        actions: {
          Button(L10n.Localizable.autofillDemoModalPrimaryAction) {
            model.isAutoFillDemoModalShown = false
            model.showAutoFillDemo()
          }
          .buttonStyle(.designSystem(.titleOnly))
          Button(L10n.Localizable.autofillDemoModalSecondaryAction) {
            model.isAutoFillDemoModalShown = false
            self.dismiss()
          }
          .buttonStyle(.designSystem(.titleOnly))
          .style(intensity: .quiet)
        },
        header: {
          AutoFillOnboardingSheetHeaderView()
        }
      )
    }
    .makeShortcuts(model: model)
    .detailContainerViewSpecificSave(.init(model.save))
  }

  var mainSection: some View {
    CredentialMainSection(
      model: model.credentialMainSectionModelFactory.make(
        service: model.service,
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

  var passwordHealthSection: some View {
    PasswordHealthSection(model: model.passwordHealthSectionModel)
  }

  var sharingSection: some View {
    SharingDetailSection(
      model: model.sharingDetailSectionModelFactory.make(item: model.item),
      ctaLabel: L10n.Localizable.kwSharePassword,
      canShare: !model.service.isFrozen
    )
  }

  var notesSection: some View {
    NotesSection(model: model.notesSectionModelFactory.make(service: model.service))
  }
}

private struct AutoFillOnboardingSheetHeaderView: View {
  @ScaledMetric private var dimension = 220

  var body: some View {
    LottieView(.onboardingAutofill)
      .frame(
        width: dimension,
        height: dimension
      )
  }
}

extension CredentialDetailView {
  fileprivate func addedDomainsList(isAdditionMode: Bool = false) -> some View {

    return CredentialDomainsView(model: model.makeDomainsViewModel(from: isAdditionMode))
  }
}

struct CredentialDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      CredentialDetailView(
        model: MockVaultConnectedContainer().makeCredentialDetailViewModel(
          item: PersonalDataMock.Credentials.amazon, mode: .viewing))
      CredentialDetailView(
        model: MockVaultConnectedContainer().makeCredentialDetailViewModel(
          item: PersonalDataMock.Credentials.amazon, mode: .adding(prefilled: false)))
      CredentialDetailView(
        model: MockVaultConnectedContainer().makeCredentialDetailViewModel(
          item: PersonalDataMock.Credentials.amazon, mode: .updating))
    }
  }
}
