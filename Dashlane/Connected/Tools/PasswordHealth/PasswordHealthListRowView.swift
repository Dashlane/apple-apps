import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit
import CoreLocalization

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
            Image.ds.action.more.outlined
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fiberAccessibilityLabel(Text(CoreLocalization.L10n.Core.kwActions))
                .frame(width: 24, height: 40)
                .foregroundColor(.ds.text.brand.quiet)
        }
    }
}
