import SwiftUI
import DashlaneAppKit
import CoreSettings
import DesignSystem

struct VaultSortingSelector: View {
    let title: String

    @Binding
    var sorting: VaultItemSorting

    @State
    var isActionSheetPresented: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text(sorting.title)
                    .font(.caption)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .id(sorting.title)

                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
            }
            .foregroundColor(.ds.text.neutral.catchy)
        }
        .onTapGesture {
            self.isActionSheetPresented = true
        }
        .actionSheet(isPresented: $isActionSheetPresented) {
            let buttons: [ActionSheet.Button] = VaultItemSorting.allCases.map { sorting in
                return ActionSheet.Button.default(Text(sorting.title).foregroundColor(Color.red)) {
                    self.sorting = sorting
                }
            }
            return ActionSheet(title: Text(L10n.Localizable.kwSortBy),
                               message: nil,
                               buttons: buttons + [.cancel()])
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: sorting)
    }
}

struct SortingSelector_Previews: PreviewProvider {
    static var previews: some View {
        VaultSortingSelector(title: "Test", sorting: .constant(.sortedByCategory))
    }
}
