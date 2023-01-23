import SwiftUI
import DashlaneAppKit
import CoreSettings
import DesignSystem

struct VaultItemSortingButton: View {

    var select: (VaultItemSorting) -> Void

    var body: some View {
        Menu {
            ForEach(VaultItemSorting.allCases, id: \.self) { item in
                Button(item.title) {
                    select(item)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.ds.text.brand.standard)
        }

    }
}
