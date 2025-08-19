import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIDelight

public struct AddVaultButton<Label: View>: View {
  @FeatureState(.disableSecureNotes)
  var isSecureNoteDisabled

  @FeatureState(.wifiCredential)
  var isWiFiCredentialsEnabled

  @FeatureState(.importDataButton)
  var isImportDataButtonEnabled

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  public enum Action {
    case add(VaultItem.Type)
    case `import`
  }

  let label: Label
  let isImportEnabled: Bool
  let category: ItemCategory?
  let onAction: (Action) -> Void

  private var isDisabled: Bool {
    return isSecureNoteDisabled && category == .secureNotes
  }

  public init(
    category: ItemCategory? = nil,
    isImportEnabled: Bool,
    onAction: @escaping (Action) -> Void,
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.isImportEnabled = isImportEnabled
    self.category = category
    self.onAction = onAction
  }

  public var body: some View {
    if let category = category, category.hasOnlyOneItemType, let item = category.items.first {
      Button {
        onAction(.add(item.type))
      } label: {
        label
      }
      .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
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

        if isImportDataButtonEnabled && isImportEnabled {
          Divider()
          Button {
            onAction(.import)
          } label: {
            HStack {
              Text(L10n.Core.vauldAddButtonImportData)
              Image.ds.download.outlined
            }
          }
        }
      } label: {
        label
      }
      .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
      .disabled(isDisabled)
    }
  }

  private var enabledCategories: [ItemCategory] {
    ItemCategory.allCases.lazy
      .filter { category in
        switch category {
        case .secrets:
          return secretManagementStatus.isAvailable
        case .wifi:
          return isWiFiCredentialsEnabled
        default:
          return true
        }
      }
  }
}

extension AddVaultButton {
  @ViewBuilder
  private func button(for category: ItemCategory) -> some View {
    if isSecureNoteDisabled && category == .secureNotes {
      EmptyView()
    } else if !isWiFiCredentialsEnabled && category == .wifi {
      EmptyView()
    } else if category.hasOnlyOneItemType, let item = category.items.first {
      button(for: item.type)
    } else {
      Menu {
        ForEach(category.items) { item in
          button(for: item.type)
        }
      } label: {
        HStack {
          Text(category.nativeMenuAddTitle)
          category.icon
        }
      }
    }
  }

  @ViewBuilder
  private func button(for itemType: VaultItem.Type) -> some View {
    Button {
      onAction(.add(itemType))
    } label: {
      HStack {
        Text(itemType.nativeMenuAddTitle)
        itemType.addIcon
      }
    }
  }
}

extension ItemCategory {
  var hasOnlyOneItemType: Bool {
    return items.count == 1
  }
}

extension AddVaultButton where Label == NavigationBarAddIcon {
  public init(
    isImportEnabled: Bool,
    category: ItemCategory? = nil,
    onAction: @escaping (Action) -> Void
  ) {
    self.init(
      category: category,
      isImportEnabled: isImportEnabled,
      onAction: onAction
    ) {
      NavigationBarAddIcon()
    }
  }
}

extension AddVaultButton where Label == Text {
  public init(
    text: Text,
    isImportEnabled: Bool,
    category: ItemCategory? = nil,
    onAction: @escaping (Action) -> Void
  ) {
    self.init(
      category: category,
      isImportEnabled: isImportEnabled,
      onAction: onAction
    ) {
      text
    }
  }
}

#Preview("Add icon button", traits: .sizeThatFitsLayout) {
  AddVaultButton(isImportEnabled: true, onAction: { _ in })
}

#Preview("Add icon button with disabled secure note in menu", traits: .sizeThatFitsLayout) {
  AddVaultButton(isImportEnabled: true, onAction: { _ in })
    .environment(\.enabledFeatures, [.disableSecureNotes])
}

#Preview("Add icon secure note button with disabled secure note", traits: .sizeThatFitsLayout) {
  AddVaultButton(isImportEnabled: true, category: .secureNotes, onAction: { _ in })
    .environment(\.enabledFeatures, [.disableSecureNotes])
}

#Preview("Add text button with menu", traits: .sizeThatFitsLayout) {
  AddVaultButton(text: Text("Add Item"), isImportEnabled: true, onAction: { _ in })
}

#Preview("Add text button with no menu", traits: .sizeThatFitsLayout) {
  AddVaultButton(text: Text("Add Item"), isImportEnabled: true, onAction: { _ in })
}

#Preview("Add text secure button with disabled secure note", traits: .sizeThatFitsLayout) {
  AddVaultButton(
    text: Text("Add Item"),
    isImportEnabled: true, category: .secureNotes, onAction: { _ in }
  )
  .environment(\.enabledFeatures, [.disableSecureNotes])
}
