import Combine
import CoreLocalization
import CorePasswords
import CorePersonalData
import CoreTypes
import DesignSystem
import DesignSystemExtra
import DomainParser
import IconLibrary
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation
import VaultKit

struct EditableDomain: Identifiable {
  let id: UUID
  var content: LinkedServices.AssociatedDomain
  init(id: UUID = UUID(), content: LinkedServices.AssociatedDomain) {
    self.id = id
    self.content = content
  }
}

struct DuplicatePrompt {
  let domain: EditableDomain
  let title: String
  let completion: () -> Void
}

struct CredentialDomainsView: View {

  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  var model: CredentialDomainsViewModel
  @State var editMode: EditMode = .inactive
  @FocusState private var domainIdToEdit: UUID?
  @State var lastIdDuplicateChecked: UUID?

  init(model: @escaping @autoclosure () -> CredentialDomainsViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    List {
      mainWebsite
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      services
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      associatedWebsites
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .listStyle(.ds.insetGrouped)
    .alert(using: $model.duplicatedCredential, content: { alertView(duplicatedCredential: $0) })
    .navigationBarTitle(CoreL10n.KWAuthentifiantIOS.Domains.title, displayMode: .inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      toolbarContent
    }
    .environment(\.editMode, self.$editMode)
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
        domainIdToEdit = model.addedDomains.first(where: { $0.content.domain.isEmpty })?.id
      }
    }
    .onDisappear {
      if (model.initialMode.isEditing || !editMode.isEditing) && !model.isAdditionMode {
        model.save()
      }
    }
    .onChange(of: domainIdToEdit) { _, domainIdToCheck in
      guard let domainIdToCheck = domainIdToCheck else {
        return
      }
      checkDuplicatesByPresentingAlert(keepFocusState: true) {}
      lastIdDuplicateChecked = domainIdToCheck
    }
    .reportPageAppearance(.itemCredentialDetailsWebsites)
    .task {
      self.editMode = self.model.initialMode.isEditing ? .active : .inactive
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      if model.isAdditionMode {
        Button(CoreL10n.cancel) { dismiss() }
          .tint(.ds.text.brand.standard)
      } else {
        NativeNavigationBarBackButton(
          CoreL10n.kwBack,
          action: {
            if editMode.isEditing {
              checkDuplicatesByPresentingAlert {
                dismiss()
              }
            } else {
              dismiss()
            }
          })
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      trailingButton
    }
  }

  @ViewBuilder
  private var trailingButton: some View {
    if model.canAddDomain {
      if model.isAdditionMode {
        Button(CoreL10n.kwDoneButton) {
          checkDuplicatesByPresentingAlert {
            model.save()
            dismiss()
          }
        }
      } else if !editMode.isEditing {
        if !model.initialMode.isEditing {
          EditButton()
            .tint(.ds.text.brand.standard)
        }
      } else {
        if !model.initialMode.isEditing {
          Button(CoreL10n.kwSave) {
            checkDuplicatesByPresentingAlert {
              editMode = .inactive
              model.save()
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  var mainWebsite: some View {
    if let url = model.item.url?.rawValue {
      DomainsSectionView(
        sectionTitle: CoreL10n.KWAuthentifiantIOS.Domains.main,
        domains: [url],
        isOpenable: !editMode.isEditing)
    }
  }

  @ViewBuilder
  var services: some View {
    if editMode.isEditing && model.canAddDomain {
      servicesUpdating
    } else if model.addedDomains.count > 0 {
      servicesReading
    }
  }

  var servicesReading: some View {
    DomainsSectionView(
      sectionTitle: CoreL10n.KWAuthentifiantIOS.Domains.addedByYou,
      domains: model.addedDomains.map { $0.content.domain },
      isOpenable: !editMode.isEditing)
  }

  var servicesUpdating: some View {
    Section(header: Text(CoreL10n.KWAuthentifiantIOS.Domains.addedByYou.uppercased())) {
      ForEach($model.addedDomains) { $addedDomain in
        TextField(
          CoreL10n.KWAuthentifiantIOS.Domains.placeholder, text: $addedDomain.content.domain
        )
        .focused($domainIdToEdit, equals: addedDomain.id)
        .keyboardType(.URL)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
      }
      .onDelete { indexSet in
        model.addedDomains.remove(atOffsets: indexSet)
      }

      Button(
        action: {
          guard !model.addedDomains.contains(where: { $0.content.domain.count == 0 }) else {
            return
          }
          let domainToAppend = EditableDomain(
            content: LinkedServices.AssociatedDomain(domain: "", source: .manual))
          model.addedDomains.append(domainToAppend)
          domainIdToEdit = domainToAppend.id
        },
        label: {
          HStack {
            Image(systemName: "plus.circle.fill")
              .foregroundStyle(Color.ds.text.positive.standard)
              .scaleEffect(1.3)
              .padding(.horizontal, 2)
            Text(CoreL10n.KWAuthentifiantIOS.Domains.add)
              .foregroundStyle(Color.ds.text.brand.standard)
              .padding(.leading, 8)
          }
        }
      )
      .buttonStyle(.plain)
    }
  }

  var associatedWebsites: some View {
    DomainsSectionView(
      sectionTitle: CoreL10n.KWAuthentifiantIOS.Domains.automaticallyAdded,
      domains: model.linkedDomains,
      isOpenable: !editMode.isEditing)
  }

  private func checkDuplicatesByPresentingAlert(
    keepFocusState: Bool = false, completion: @escaping () -> Void
  ) {
    guard let lastIdDuplicateChecked else {
      completion()
      return
    }

    if keepFocusState == false {
      domainIdToEdit = nil
    }

    model.checkDuplicate(of: lastIdDuplicateChecked) {
      completion()
    }
  }

  private func alertView(duplicatedCredential: DuplicatePrompt) -> Alert {
    let completion = duplicatedCredential.completion
    return Alert(
      title: Text(
        CoreL10n.KWAuthentifiantIOS.Domains.Duplicate.title(
          duplicatedCredential.domain.content.domain)),
      message: Text(CoreL10n.KWAuthentifiantIOS.Domains.duplicate(duplicatedCredential.title)),
      primaryButton: Alert.Button.cancel(
        Text(CoreL10n.cancel),
        action: {
          self.model.addedDomains.removeAll(where: { duplicatedCredential.domain.id == $0.id })
          completion()
        }),
      secondaryButton: Alert.Button.default(
        Text(CoreL10n.addWebsite),
        action: {
          completion()
        }))
  }
}

extension LinkedServices.AssociatedDomain: Identifiable {
  public var id: String {
    return self.domain
  }
}

struct CredentialDomainsView_Previews: PreviewProvider {

  static let credential: Credential = PersonalDataMock.Credentials.amazon

  static let linkedServices: [LinkedServices.AssociatedDomain] = [
    LinkedServices.AssociatedDomain(domain: "live.com", source: DomainSource.remember),
    LinkedServices.AssociatedDomain(domain: "outlook.com", source: DomainSource.manual),
  ]

  func model(mode: DetailMode) -> CredentialDomainsViewModel {
    CredentialDomainsViewModel(
      item: CredentialDomainsView_Previews.credential,
      isAdditionMode: false,
      initialMode: mode,
      isFrozen: false,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      activityReporter: .mock,
      updatePublisher: PassthroughSubject<
        CredentialDetailViewModel.LinkedServicesUpdate,
        Never
      >()
    )
  }

  static var previews: some View {
    MultiContextPreview {
      NavigationView {
        CredentialDomainsView(model: CredentialDomainsView_Previews().model(mode: .viewing))
      }
      NavigationView {
        CredentialDomainsView(model: CredentialDomainsView_Previews().model(mode: .updating))
      }
    }
  }
}
