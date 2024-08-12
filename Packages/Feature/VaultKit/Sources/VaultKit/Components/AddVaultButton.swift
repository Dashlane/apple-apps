import CoreFeature
import CorePersonalData
import CorePremium
import SwiftUI
import UIComponents
import UIDelight

public struct AddVaultButton<Label: View>: View {
  @CapabilityState(.secureNotes)
  var secureNoteState

  @FeatureState(.disableSecureNotes)
  var isSecureNoteDisabled

  @FeatureState(.vaultSecrets)
  var areSecretsEnabled

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  let label: Label
  let category: ItemCategory?
  let onTap: () -> Void
  let selectAction: (VaultItem.Type) -> Void

  private var isDisabled: Bool {
    return isSecureNoteDisabled && category == .secureNotes
  }

  public init(
    category: ItemCategory? = nil,
    onTap: @escaping () -> Void = {},
    selectAction: @escaping (VaultItem.Type) -> Void,
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.category = category
    self.onTap = onTap
    self.selectAction = selectAction
  }

  public var body: some View {
    if let category = category, category.hasOnlyOneItemType, let item = category.items.first {
      Button {
        onTap()
        selectAction(item.type)
      } label: {
        label
          .contentShape(Rectangle())
      }
      .buttonStyle(ColoredButtonStyle())
      .disabled(isDisabled)
    } else {
      Menu {
        if let category = category {
          ForEach(category.items) { item in
            button(for: item.type)
          }
        } else {
          ForEach(enabledCategories) { category in
            button(for: category)
          }
        }
      } label: {
        label
          .contentShape(Rectangle())
          .foregroundColor(.ds.text.brand.standard)
          .fiberAccessibilityRemoveTraits(.isImage)
          .fiberAccessibilityAddTraits(.isButton)
      }
      .onTapGesture(perform: onTap)
      .disabled(isDisabled)
    }
  }

  private var enabledCategories: [ItemCategory] {
    let filters = ItemCategory.allCases
    let isSecretsManagementAvailable = areSecretsEnabled && secretManagementStatus.isAvailable
    return isSecretsManagementAvailable ? filters : filters.filter { $0 != .secrets }
  }
}

extension AddVaultButton {
  @ViewBuilder
  private func button(for category: ItemCategory) -> some View {
    if isSecureNoteDisabled && category == .secureNotes {
      EmptyView()
    } else if category.hasOnlyOneItemType, let item = category.items.first {
      button(for: item.type, icon: icon(for: category))
    } else {
      Menu {
        ForEach(category.items) { item in
          button(for: item.type, icon: icon(for: category))
        }
      } label: {
        HStack {
          Text(category.nativeMenuAddTitle)
          icon(for: category)
          category.icon
        }
      }
    }
  }

  private func icon(for category: ItemCategory) -> SwiftUI.Image? {
    switch category {
    case .secureNotes:
      return !isSecureNoteDisabled && secureNoteState == .needsUpgrade
        ? Image(asset: Asset.imgNoteLocked) : nil
    default:
      return nil
    }
  }

  @ViewBuilder
  private func button(for itemType: VaultItem.Type, icon: SwiftUI.Image? = nil) -> some View {
    Button {
      selectAction(itemType)
    } label: {
      HStack {
        Text(itemType.nativeMenuAddTitle)
        icon ?? itemType.addIcon
      }
    }
  }
}

extension ItemCategory {
  var hasOnlyOneItemType: Bool {
    return items.count == 1
  }
}

public struct NavigationBarAddIcon: View {
  public var body: some View {
    Image(asset: Asset.addButton)
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
  }
}

extension AddVaultButton where Label == NavigationBarAddIcon {
  public init(
    category: ItemCategory? = nil,
    onTap: @escaping () -> Void = {},
    selectAction: @escaping (VaultItem.Type) -> Void
  ) {
    self.init(
      category: category,
      onTap: onTap,
      selectAction: selectAction
    ) {
      NavigationBarAddIcon()
    }
  }
}

extension AddVaultButton where Label == Text {
  public init(
    text: Text,
    category: ItemCategory? = nil,
    onTap: @escaping () -> Void = {},
    selectAction: @escaping (VaultItem.Type) -> Void
  ) {
    self.init(
      category: category,
      onTap: onTap,
      selectAction: selectAction
    ) {
      text
    }
  }
}

struct AddVaultButton_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      AddVaultButton { _ in }
        .previewDisplayName("Add icon button")

      AddVaultButton { _ in }
        .environment(\.enabledFeatures, [.disableSecureNotes])
        .previewDisplayName("Add icon button with disabled secure note in menu")

      AddVaultButton(category: .secureNotes) { _ in }
        .environment(\.enabledFeatures, [.disableSecureNotes])
        .previewDisplayName("Add icon secure note button with disabled secure note")

      AddVaultButton(text: Text("Add Item")) { _ in }
        .previewDisplayName("Add text button with menu")

      AddVaultButton(
        text: Text("Add Item"),
        category: .credentials
      ) { _ in }
      .previewDisplayName("Add text button with no menu")

      AddVaultButton(
        text: Text("Add Item"),
        category: .secureNotes
      ) { _ in }
      .previewDisplayName("Add text secure button with disabled secure note")
      .environment(\.enabledFeatures, [.disableSecureNotes])

    }
    .previewLayout(.sizeThatFits)
  }
}
