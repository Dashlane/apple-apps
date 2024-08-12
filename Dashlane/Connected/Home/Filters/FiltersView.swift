import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreUserTracking
import SwiftUI
import VaultKit

struct FiltersView: View {
  @Binding var activeFilter: ItemCategory?

  @FeatureState(.vaultSecrets)
  var areSecretsEnabled: Bool

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        filterButton(for: nil)

        ForEach(enabledFilters) { filter in
          filterButton(for: filter)
        }
      }
      .padding(.horizontal, 16)
    }
    .padding(.bottom, 10)
    .background(Color.clear)
  }

  private var enabledFilters: [ItemCategory] {
    let filters = ItemCategory.allCases
    let isSecretsManagementAvailable = areSecretsEnabled && secretManagementStatus.isAvailable
    return isSecretsManagementAvailable ? filters : filters.filter { $0 != .secrets }
  }

  private func filterButton(for filter: ItemCategory?) -> some View {
    Button(filter.title) {
      activeFilter = filter
    }
    .buttonStyle(FilterButtonStyle(isSelected: filter == activeFilter))
    .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityTraitTab(filter.title)))
    .fiberAccessibilityAddTraits(filter == activeFilter ? .isSelected : [])
  }
}

struct FilterButtonStyle: ButtonStyle {
  let isSelected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .padding(.vertical, 6)
      .padding(.horizontal, 10)
      .background(backgroundColor)
      .foregroundColor(foregroundColor)
      .cornerRadius(6)
      .opacity(configuration.isPressed ? 0.5 : 1.0)

  }

  var backgroundColor: Color {
    isSelected
      ? .ds.container.expressive.neutral.catchy.active : .ds.container.expressive.neutral.quiet.idle
  }

  var foregroundColor: Color {
    isSelected ? .ds.text.inverse.catchy : .ds.text.neutral.standard
  }
}

extension ItemCategory? {
  var title: String {
    switch self {
    case nil:
      return CoreLocalization.L10n.Core.itemsTitle
    case .credentials:
      return CoreLocalization.L10n.Core.mainMenuLoginsAndPasswords
    case .secureNotes:
      return CoreLocalization.L10n.Core.mainMenuNotes
    case .payments:
      return CoreLocalization.L10n.Core.mainMenuPayment
    case .personalInfo:
      return CoreLocalization.L10n.Core.mainMenuContact
    case .ids:
      return CoreLocalization.L10n.Core.mainMenuIDs
    case .secrets:
      return CoreLocalization.L10n.Core.mainMenuSecrets
    }
  }
}
