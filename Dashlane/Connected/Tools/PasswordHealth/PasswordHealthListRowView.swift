import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct PasswordHealthListRowView: View, SessionServicesInjecting {

  let item: Credential
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  let exclude: () -> Void
  let replace: () -> Void
  let detail: (Credential) -> Void

  init(
    item: Credential,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    exclude: @escaping () -> Void,
    replace: @escaping () -> Void,
    detail: @escaping (Credential) -> Void
  ) {
    self.item = item
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.exclude = exclude
    self.replace = replace
    self.detail = detail
  }

  var body: some View {
    HStack(spacing: 16) {
      VaultItemRow(
        item: item,
        userSpace: nil,
        vaultIconViewModelFactory: vaultItemIconViewModelFactory
      )
      .onTapWithFeedback {
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
        title: item.disabledForPasswordAnalysis
          ? L10n.Localizable.securityDashboardActionInclude
          : L10n.Localizable.securityDashboardActionExclude
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

extension PasswordHealthListRowView {
  static func mock(item: Credential) -> PasswordHealthListRowView {
    PasswordHealthListRowView(
      item: item,
      vaultItemIconViewModelFactory: .init({ item in .mock(item: item) }),
      exclude: {},
      replace: {},
      detail: { _ in })
  }
}
