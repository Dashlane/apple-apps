import Combine
import CoreLocalization
import CorePasswords
import CorePersonalData
import CoreUserTracking
import DashTypes
import DesignSystem
import IconLibrary
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct EditableDomain: Identifiable {
  let id: UUID = UUID()
  var content: LinkedServices.AssociatedDomain
}

struct DuplicatePrompt {
  let domain: EditableDomain
  let title: String
  let completion: ([EditableDomain]) -> Void
}

struct CredentialDomainsView: View {

  @Environment(\.dismiss)
  private var dismiss

  var model: CredentialDomainsViewModel
  @State var addedDomains: [EditableDomain]
  @State var duplicatedCredential: DuplicatePrompt?
  @State var editMode: EditMode
  @FocusState private var domainIdToEdit: UUID?
  @State var lastIdDuplicateChecked: UUID?

  init(model: CredentialDomainsViewModel, addedDomains: [LinkedServices.AssociatedDomain]) {
    self.model = model
    self._addedDomains = State(
      initialValue: addedDomains.map {
        EditableDomain(content: $0)
      })
    self._editMode = State(initialValue: model.initialMode.isEditing ? .active : .inactive)
  }

  var body: some View {
    List {
      mainWebsite
      services
      associatedWebsites
    }
    .detailListStyle()
    .alert(using: $duplicatedCredential, content: { alertView(duplicatedCredential: $0) })
    .navigationBarTitle(
      CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.title, displayMode: .inline
    )
    .navigationBarBackButtonHidden(true)
    .toolbar {
      toolbarContent
    }
    .environment(\.editMode, self.$editMode)
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
        domainIdToEdit = addedDomains.first(where: { $0.content.domain.isEmpty })?.id
      }
    }
    .onDisappear {
      if (model.initialMode.isEditing || !editMode.isEditing) && !model.isAdditionMode {
        commit(domains: self.addedDomains)
      }
    }
    .onChange(
      of: domainIdToEdit,
      perform: { domainIdToCheck in
        guard let domainIdToCheck = domainIdToCheck else {
          return
        }
        checkDuplicate(of: lastIdDuplicateChecked)
        lastIdDuplicateChecked = domainIdToCheck
      }
    )
    .reportPageAppearance(.itemCredentialDetailsWebsites)
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      if model.isAdditionMode {
        Button(action: { dismiss() }, title: CoreLocalization.L10n.Core.cancel)
          .tint(.ds.text.brand.standard)
      } else {
        BackButton(
          label: CoreLocalization.L10n.Core.kwBack,
          action: {
            if editMode.isEditing {
              checkDuplicate(of: lastIdDuplicateChecked) { _ in
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
        NavigationBarButton(CoreLocalization.L10n.Core.kwDoneButton) {
          checkDuplicate(of: lastIdDuplicateChecked) { domains in
            commit(domains: domains)
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
          NavigationBarButton(CoreLocalization.L10n.Core.kwSave) {
            checkDuplicate(of: lastIdDuplicateChecked) { domains in
              editMode = .inactive
              let domainsToSave = domains.filter { !$0.content.domain.isEmpty }
              model.save(
                addedDomains: LinkedServices(associatedDomains: domainsToSave.map { $0.content }))
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
        sectionTitle: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.main,
        domains: [url],
        isOpenable: !editMode.isEditing)
    }
  }

  @ViewBuilder
  var services: some View {
    if editMode.isEditing && model.canAddDomain {
      servicesUpdating
    } else if addedDomains.count > 0 {
      servicesReading
    }
  }

  var servicesReading: some View {
    DomainsSectionView(
      sectionTitle: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.addedByYou,
      domains: addedDomains.map { $0.content.domain },
      isOpenable: !editMode.isEditing)
  }

  var servicesUpdating: some View {
    Section(
      header: Text(CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.addedByYou.uppercased())
    ) {
      ForEach($addedDomains) { $addedDomain in
        TextField(
          CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.placeholder,
          text: $addedDomain.content.domain
        )
        .focused($domainIdToEdit, equals: addedDomain.id)
        .keyboardType(.URL)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
      }
      .onDelete { indexSet in
        addedDomains.remove(atOffsets: indexSet)
      }

      Button(
        action: {
          guard !addedDomains.contains(where: { $0.content.domain.count == 0 }) else {
            return
          }
          let domainToAppend = EditableDomain(
            content: LinkedServices.AssociatedDomain(domain: "", source: .manual))
          addedDomains.append(domainToAppend)
          domainIdToEdit = domainToAppend.id
        },
        label: {
          HStack {
            Image(systemName: "plus.circle.fill")
              .foregroundColor(.ds.text.positive.standard)
              .scaleEffect(1.3)
              .padding(.horizontal, 2)
            Text(CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.add)
              .foregroundColor(.ds.text.brand.standard)
              .padding(.leading, 8)
          }
        }
      )
      .buttonStyle(.plain)
    }
  }

  var associatedWebsites: some View {
    DomainsSectionView(
      sectionTitle: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.automaticallyAdded,
      domains: model.linkedDomains,
      isOpenable: !editMode.isEditing)
  }

  private func commit(domains: [EditableDomain]) {
    let domainsToCommit = domains.filter { !$0.content.domain.isEmpty }
    model.commit(
      addedDomains: LinkedServices(associatedDomains: domainsToCommit.map { $0.content }))
  }

  private func alertView(duplicatedCredential: DuplicatePrompt) -> Alert {
    let completion = duplicatedCredential.completion
    return Alert(
      title: Text(
        CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.Duplicate.title(
          duplicatedCredential.domain.content.domain)),
      message: Text(
        CoreLocalization.L10n.Core.KWAuthentifiantIOS.Domains.duplicate(duplicatedCredential.title)),
      primaryButton: Alert.Button.cancel(
        Text(CoreLocalization.L10n.Core.cancel),
        action: {
          DispatchQueue.main.async {
            self.addedDomains.removeAll(where: { duplicatedCredential.domain.id == $0.id })
          }
          completion(self.addedDomains.filter { duplicatedCredential.domain.id != $0.id })
        }),
      secondaryButton: Alert.Button.default(
        Text(CoreLocalization.L10n.Core.addWebsite),
        action: {
          completion(self.addedDomains)
        }))
  }

  private func checkDuplicate(
    of uuid: UUID?, completion: @escaping ([EditableDomain]) -> Void = { _ in }
  ) {
    guard let addedDomain = addedDomains.first(where: { $0.id == uuid }),
      duplicatedCredential == nil
    else {
      completion(self.addedDomains)
      return
    }

    if let duplicate = model.hasDuplicate(for: addedDomain.content.domain) {
      duplicatedCredential = DuplicatePrompt(
        domain: addedDomain, title: duplicate.displayTitle, completion: completion)
      return
    }

    if addedDomains.filter({ $0.content.domain == addedDomain.content.domain }).count > 1 {
      duplicatedCredential = DuplicatePrompt(
        domain: addedDomain, title: model.item.displayTitle, completion: completion)
      return
    }

    if !model.linkedDomains.filter({ $0 == addedDomain.content.domain }).isEmpty {
      duplicatedCredential = DuplicatePrompt(
        domain: addedDomain, title: model.item.displayTitle, completion: completion)
      return
    }

    if duplicatedCredential == nil {
      completion(self.addedDomains)
    }
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
        CredentialDomainsView(
          model: CredentialDomainsView_Previews().model(mode: .viewing),
          addedDomains: CredentialDomainsView_Previews.linkedServices)
      }
      NavigationView {
        CredentialDomainsView(
          model: CredentialDomainsView_Previews().model(mode: .updating),
          addedDomains: CredentialDomainsView_Previews.linkedServices)
      }
    }
  }
}
