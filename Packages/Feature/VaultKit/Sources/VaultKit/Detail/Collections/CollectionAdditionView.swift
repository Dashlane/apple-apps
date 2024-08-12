import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

public struct CollectionAdditionView: View {

  public enum Completion {
    case cancel
    case create(collectionName: String)
    case select(collection: VaultCollection)
  }

  let item: VaultItem

  let allCollections: [VaultCollection]

  let collections: [VaultCollection]
  let completion: (Completion) -> Void

  @State
  private var newCollectionName: String = ""

  @State
  private var showSharedCollectionDialog: Bool = false

  @State
  private var showLimitedRightsErrorMessage: Bool = false

  @State
  private var collectionToModify: VaultCollection?

  @FocusState
  private var textFieldFocus

  private var formattedCollectionName: String {
    newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var isNameAlreadyExisting: Bool {
    allCollections.contains(where: { $0.name == formattedCollectionName })
  }

  private var canBeCreatedOrAdded: Bool {
    !formattedCollectionName.isEmpty && !isNameAlreadyExisting
  }

  private var filteredCollections: [VaultCollection] {
    collections.filterAndSortItemsUsingCriteria(formattedCollectionName)
  }

  public init(
    item: VaultItem,
    allCollections: [VaultCollection],
    collections: [VaultCollection],
    completion: @escaping (Completion) -> Void
  ) {
    self.item = item
    self.allCollections = allCollections.sortedByName()
    self.collections = collections.sortedByName()
    self.completion = completion
  }

  public var body: some View {
    NavigationView {
      List {
        Section {
          TextField(L10n.Core.KWVaultItem.Collections.add, text: $newCollectionName)
            .submitLabel(.done)
            .focused($textFieldFocus)
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)
            .onSubmit(createOrAdd)
            .onReceive(Just(newCollectionName)) { _ in
              guard newCollectionName.count > VaultCollection.maxNameLength else { return }
              newCollectionName = String(newCollectionName.prefix(VaultCollection.maxNameLength))
            }

          if canBeCreatedOrAdded {
            collectionRow(name: formattedCollectionName)
          }

          ForEach(filteredCollections) { collection in
            collectionRow(collection)
          }
        }
      }
      .listStyle(.insetGrouped)
      .background(Color.ds.background.alternate)
      .scrollContentBackground(.hidden)
      .padding(.top, -16)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { completion(.cancel) }, title: L10n.Core.cancel)
        }
      }
      .tint(.ds.text.brand.standard)
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
          self.textFieldFocus = true
        }
      }
      .alert(isPresented: $showLimitedRightsErrorMessage) {
        Alert(
          title: Text(L10n.Core.KWVaultItem.Collections.Sharing.LimitedRights.Addition.Error.title),
          message: Text(
            L10n.Core.KWVaultItem.Collections.Sharing.LimitedRights.Addition.Error.message),
          dismissButton: .default(Text(L10n.Core.kwButtonOk))
        )
      }
      .confirmationDialog(
        L10n.Core.KWVaultItem.Collections.Sharing.AdditionAlert.title(item.localizedTitle),
        isPresented: $showSharedCollectionDialog,
        titleVisibility: .visible,
        presenting: collectionToModify,
        actions: { collection in
          Button(L10n.Core.KWVaultItem.Collections.Sharing.AdditionAlert.button) {
            completion(.select(collection: collection))
          }
        },
        message: { collection in
          Text(L10n.Core.KWVaultItem.Collections.Sharing.AdditionAlert.message(collection.name))
        }
      )
    }
  }

  func collectionRow(name: String) -> some View {
    Button(
      action: { completion(.create(collectionName: name)) },
      label: {
        HStack {
          Text(L10n.Core.KWVaultItem.Collections.create)
            .font(.body)
            .lineLimit(1)
            .foregroundColor(.ds.text.brand.standard)

          Tag(name)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    )
    .buttonStyle(.plain)
  }

  func collectionRow(_ collection: VaultCollection) -> some View {
    Button(
      action: { select(collection: collection) },
      label: {
        HStack {
          Tag(
            collection.name,
            trailingAccessory: collection.isShared ? .icon(.ds.shared.outlined) : nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
      }
    )
    .buttonStyle(.plain)
  }

  private func select(collection: VaultCollection) {
    if collection.isShared {
      switch item.metadata.sharingPermission {
      case .admin:
        collectionToModify = collection
        showSharedCollectionDialog = true
      case .limited, .none:
        showLimitedRightsErrorMessage = true
      }
    } else {
      completion(.select(collection: collection))
    }
  }

  private func createOrAdd() {
    guard canBeCreatedOrAdded else { return }
    if let collection = allCollections.first(where: { $0.name == formattedCollectionName }) {
      completion(.select(collection: collection))
    } else {
      completion(.create(collectionName: formattedCollectionName))
    }
  }
}

struct CollectionAdditionView_Previews: PreviewProvider {
  static var previews: some View {
    CollectionAdditionView(
      item: PersonalDataMock.Credentials.adobe,
      allCollections: [PersonalDataMock.Collections.finance].map(VaultCollection.init(collection:)),
      collections: [PersonalDataMock.Collections.business].map(VaultCollection.init(collection:))
    ) { _ in }
  }
}
