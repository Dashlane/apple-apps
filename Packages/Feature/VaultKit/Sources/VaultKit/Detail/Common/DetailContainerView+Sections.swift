import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

extension DetailContainerView {

  @ViewBuilder
  var itemOrganizationSection: some View {
    if model.availableUserSpaces.count > 1 || showCollections {
      Section(CoreL10n.KWVaultItem.Organization.Section.title) {
        if model.availableUserSpaces.count > 1 {
          SpaceSelectorRow(
            selectedUserSpace: model.selectedUserSpace,
            isUserSpaceForced: model.isUserSpaceForced,
            showSpaceSelector: $showSpaceSelector
          )
        }

        if showCollections {
          CollectionsSection(
            model: .init(service: model.service),
            showCollectionAddition: $showCollectionAddition
          )
        }
      }
    }
  }

  var spaceSelectorList: some View {
    SelectionListView(
      selection: Binding(
        get: { model.selectedUserSpace },
        set: { space in model.selectedUserSpace = space }
      ),
      items: model.availableUserSpaces,
      selectionDidChange: model.saveIfViewing
    )
    .tint(.ds.text.neutral.catchy)
    .navigationTitle(CoreL10n.KWAuthentifiantIOS.spaceId)
    .navigationBarTitleDisplayMode(.inline)
  }

  var showCollections: Bool {
    model.item.metadata.contentType.canBeEmbeddedInCollection
      && (!model.itemCollections.isEmpty || !model.service.isFrozen)
  }

  var collectionAdditionView: some View {
    CollectionAdditionView(
      item: model.item,
      allCollections: model.allVaultCollections.filter(bySpaceId: model.item.spaceId),
      collections: model.unusedCollections
    ) { completion in
      switch completion {
      case .create(let collectionName):
        model.addItemToNewCollection(named: collectionName)
      case .select(let collection):
        model.addItem(to: collection)
      default:
        break
      }
      showCollectionAddition = false
    }
  }

  @ViewBuilder
  var attachmentsSection: some View {
    if shouldShowAttachments {
      AttachmentsSection(model: model.makeAttachmentsSectionViewModel())
        .alert(item: $model.alert) { alert in
          switch alert {
          case .errorWhileDeletingFiles:
            return Alert(
              title: Text(CoreL10n.kwExtSomethingWentWrong),
              dismissButton: Alert.Button.default(Text(CoreL10n.kwButtonOk))
            )
          }
        }
    }
  }

  private var shouldShowAttachments: Bool {
    !model.mode.isAdding && areAttachmentsEnabled
  }

  private var areAttachmentsEnabled: Bool {
    if isDocumentStorageAllItemsEnabled {
      return true
    }

    if model.item is SecureNote {
      return true
    }

    if model.item.enumerated.isId {
      return isDocumentStorageIdsEnabled
    }

    if model.item is Secret {
      return true
    }

    return false
  }

  @ViewBuilder
  var preferencesSection: some View {
    if model.canShowLock && authenticationMethod?.supportsLock == true {
      Section(
        header: Text(CoreL10n.KWVaultItem.Preferences.Section.title),
        footer: Text(CoreL10n.KWVaultItem.Preferences.SecureToggle.message)
      ) {
        DS.Toggle(
          CoreL10n.KWVaultItem.Preferences.SecureToggle.title,
          isOn: Binding(
            get: { (model.item as? SecureItem)?.secured ?? false },
            set: { newValue in
              guard var secureItem = model.item as? SecureItem else { return }
              secureItem.secured = newValue
              guard let item = secureItem as? Item else { return }
              model.item = item
              Task {
                await model.save()
              }
            }
          )
        )
        .disabled(model.item.metadata.sharingPermission == .limited)
      }
    }
  }

  var deleteSection: some View {
    Section {
      Button(CoreL10n.kwDelete, action: askDelete)
        .foregroundStyle(Color.ds.text.danger.standard)
    }
  }
}

extension VaultItemEnumeration {
  fileprivate var isId: Bool {
    switch self {
    case .drivingLicence, .idCard, .passport, .socialSecurityInformation, .fiscalInformation:
      return true
    default:
      return false
    }
  }
}
