import SwiftUI
import CorePersonalData
import UIDelight
import DashlaneAppKit
import UIComponents
import VaultKit
import DesignSystem

struct AddItemView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.isPresented)
    private var isPresented

    @Environment(\.navigator)
    var navigator

    let items: [ItemCategory.Item]

    let title: String

    let didChooseItem: (VaultItem.Type) -> Void

    init(items: [ItemCategory.Item],
         title: String,
         didChooseItem: @escaping (VaultItem.Type) -> Void) {
        self.items = items
        self.title = title
        self.didChooseItem = didChooseItem
    }

    @ViewBuilder
    var backButton: some View {
        if isPresented {
            BackButton(action: dismiss.callAsFunction)
        } else {
            NavigationBarButton(L10n.Localizable.cancel) {
                self.navigator()?.dismiss()
            }
        }
    }

    var body: some View {
        List(items) { item in
            ItemCategoryRowView(title: item.type.addTitle,
                                icon: item.type.addIcon)
                .frame(height: 49)
                .onTapWithFeedback {
                    self.didChooseItem(item.type)
            }
        }
        .padding(.top, 40)
        .background(Color.ds.background.default)
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
    }

}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AddItemView(items: ItemCategory.payments.items,
                       title: "Add new item",
                       didChooseItem: {_ in })
        }
    }
}
