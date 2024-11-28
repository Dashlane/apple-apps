import NotificationKit
import SwiftTreats
import SwiftUI
import VaultKit

struct VaultItemsList<Header: View>: View {

  @ObservedObject
  var model: VaultItemsListViewModel

  let header: Header?

  init(
    model: VaultItemsListViewModel,
    @ViewBuilder header: () -> Header?
  ) {
    self.model = model
    self.header = header()
  }

  init(model: VaultItemsListViewModel) where Header == EmptyView {
    self.model = model
    self.header = nil
  }

  var body: some View {
    ItemsList(sections: model.sections) { configuration in
      listContent(for: configuration)
    } header: {
      header
        .listRowBackground(Color.ds.background.default)
    } footer: {
      count
        .listRowBackground(Color.ds.background.default)
    }
    .indexed(shouldHideIndexes: !model.activeFilter.supportIndexes, priority: .indexedList)
    .vaultItemsListDelete(.init(model.delete))
    .vaultItemsListDeleteBehaviour(.init(model.itemDeleteBehaviour))
    .overlay(placeholder, alignment: .bottom)
  }

  func listContent(for configuration: ItemRowViewConfiguration) -> some View {
    ActionableVaultItemRow(
      model: model.makeRowViewModel(
        configuration.vaultItem,
        isSuggestedItem: configuration.isSuggestedItem,
        origin: .vault
      )
    ) {
      let origin: VaultSelectionOrigin =
        configuration.isSuggestedItem ? .suggestedItems : .regularList
      model.select(
        .init(
          item: configuration.vaultItem,
          origin: origin,
          count: model.count(for: origin))
      )
    }
    .padding(.trailing, model.sections.count > 1 ? 10 : 0)
    .draggableItem(configuration.vaultItem)
    .vaultItemRowCollectionActions([.addToACollection, .removeFromACollection])
    .vaultItemRowEditAction(
      .init(isEnabled: configuration.vaultItem.canEditItem) {
        let origin: VaultSelectionOrigin =
          configuration.isSuggestedItem ? .suggestedItems : .regularList
        model.select(
          .init(item: configuration.vaultItem, origin: origin, count: model.count(for: origin)),
          isEditing: true
        )
      })
  }

  @ViewBuilder
  private var placeholder: some View {
    if model.sections.isEmpty {
      ListPlaceholder(
        vaultListFilter: model.activeFilter,
        canEditSecureNotes: !model.isSecureNoteDisabled,
        action: model.add
      )
      .frame(maxWidth: .infinity)
      .background(Color.ds.background.default)
    }
  }

  @ViewBuilder
  private var count: some View {
    if !Device.isIpadOrMac && model.count(for: .regularList) > 0 {
      Text(model.sectionNameForFooter())
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }

}

extension ItemCategory? {
  fileprivate var supportIndexes: Bool {
    guard let self else {
      return true
    }
    return ![.payments, .ids, .personalInfo].contains(self)
  }
}

extension ItemsList {
  @ViewBuilder
  fileprivate func indexed(shouldHideIndexes: Bool = false, priority: HomeListElementPriority)
    -> some View
  {
    self.indexed(shouldHideIndexes: shouldHideIndexes, accessibilityPriority: priority.rawValue)
  }
}

struct VaultItemsList_Previews: PreviewProvider {
  static var previews: some View {
    VaultItemsList(model: .mock)
  }
}
