import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct PasswordHealthListRowView: View {

    let item: Credential
    let vaultItemRowModel: VaultItemRowModel
    let exclude: () -> Void
    let replace: () -> Void
    let detail: (Credential) -> Void

    var body: some View {
        HStack(spacing: 16) {
            VaultItemRow(model: vaultItemRowModel) {
                detail(item)
            }
            .padding(.vertical, 10)

            actionsMenu
        }
        .fiberAccessibilityElement(children: .combine)
        .background(.ds.container.agnostic.neutral.supershy)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionsMenu: some View {
        Menu {
            Button(
                action: exclude,
                title: item.disabledForPasswordAnalysis ? L10n.Localizable.securityDashboardActionInclude : L10n.Localizable.securityDashboardActionExclude
            )
            Button(action: replace, title: L10n.Localizable.securityDashboardActionReplace)
        } label: {
            Image(asset: FiberAsset.quickaction)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fiberAccessibilityLabel(Text(L10n.Localizable.kwActions))
                .frame(width: 24, height: 40)
                .foregroundColor(.ds.text.brand.quiet)
        }
    }
}
