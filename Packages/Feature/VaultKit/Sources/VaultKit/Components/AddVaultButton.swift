import SwiftUI
import CorePersonalData
import UIDelight
import UIComponents

public struct AddVaultButton<Label: View>: View {
    let label: Label
    let secureNoteState: SecureNoteState
    let category: ItemCategory?
    let onTap: () -> Void
    let selectAction: (VaultItem.Type) -> Void

    private var isDisabled: Bool {
        return secureNoteState == .disabled && category == .secureNotes
    }

    public init(secureNoteState: SecureNoteState,
                category: ItemCategory? = nil,
                onTap: @escaping () -> Void = {},
                selectAction: @escaping (VaultItem.Type) -> Void,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.secureNoteState = secureNoteState
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
                    ForEach(ItemCategory.allCases) { category in
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
}

extension AddVaultButton {
    @ViewBuilder
    private func button(for category: ItemCategory) -> some View {
        if secureNoteState == .disabled && category == .secureNotes {
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
                return secureNoteState == .limited ? Image(asset: Asset.imgNoteLocked) : nil
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

public extension AddVaultButton where Label == NavigationBarAddIcon {
    init(secureNoteState: SecureNoteState,
         category: ItemCategory? = nil,
         onTap: @escaping () -> Void = {},
         selectAction: @escaping (VaultItem.Type) -> Void) {
        self.init(secureNoteState: secureNoteState,
                  category: category,
                  onTap: onTap,
                  selectAction: selectAction) {
            NavigationBarAddIcon()
        }
    }
}

public extension AddVaultButton where Label == Text {
    init(text: Text,
         secureNoteState: SecureNoteState,
         category: ItemCategory? = nil,
         onTap: @escaping () -> Void = {},
         selectAction: @escaping (VaultItem.Type) -> Void) {
        self.init(secureNoteState: secureNoteState,
                  category: category,
                  onTap: onTap,
                  selectAction: selectAction) {
            text
        }
    }
}

struct AddVaultButton_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AddVaultButton(secureNoteState: .enabled) { _ in }
                .previewDisplayName("Add icon button")

            AddVaultButton(secureNoteState: .disabled) { _ in }
                .previewDisplayName("Add icon button with disabled secure note in menu")

            AddVaultButton(secureNoteState: .disabled,
                           category: .secureNotes) { _ in }
                .previewDisplayName("Add icon secure note button with disabled secure note")

            AddVaultButton(text: Text("Add Item"),
                           secureNoteState: .enabled) { _ in }
                .previewDisplayName("Add text button with menu")

            AddVaultButton(text: Text("Add Item"),
                           secureNoteState: .enabled,
                           category: .credentials) { _ in }
                           .previewDisplayName("Add text button with no menu")

            AddVaultButton(text: Text("Add Item"),
                           secureNoteState: .disabled,
                           category: .secureNotes) { _ in }
                .previewDisplayName("Add text secure button with disabled secure note")
        }
        .previewLayout(.sizeThatFits)
    }
}
