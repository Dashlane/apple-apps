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
      ZStack(alignment: .selectionAlignment) {
        selectionBackground()
          .alignmentGuide(
            .selectionHorizontalAlignment, computeValue: { d in d[HorizontalAlignment.center] })

        HStack(alignment: .center, spacing: 0) {
          filterButton(for: nil)

          ForEach(enabledFilters) { filter in
            filterButton(for: filter)
          }
        }
      }
      .padding(2)
      .background(Color.ds.container.expressive.neutral.quiet.idle)
      .clipShape(RoundedRectangle(cornerRadius: 9))
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
    Group {
      if filter == activeFilter {
        Button(filter.title) {}
          .alignmentGuide(
            .selectionHorizontalAlignment, computeValue: { d in d[HorizontalAlignment.center] })
      } else {
        Button(filter.title) {
          withAnimation(.easeInOut(duration: 0.24)) {
            activeFilter = filter
          }
        }
      }
    }
    .buttonStyle(FilterButtonStyle(isSelected: filter == activeFilter))
    .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityTraitTab(filter.title)))
    .fiberAccessibilityAddTraits(filter == activeFilter ? .isSelected : [])
  }

  private func selectionBackground() -> some View {
    Text(activeFilter.title)
      .textStyle(.component.button.small)
      .padding(.vertical, 6)
      .padding(.horizontal, 10)
      .foregroundColor(.clear)
      .background {
        RoundedRectangle(cornerRadius: 7)
          .foregroundColor(.ds.container.agnostic.neutral.supershy)
          .shadow(color: .black.opacity(0.04), radius: 0.5, x: 0, y: 3)
          .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 3)
      }
  }
}

struct FilterButtonStyle: ButtonStyle {
  let isSelected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .textStyle(.component.button.small)
      .padding(.vertical, 6)
      .padding(.horizontal, 10)
      .background(Color.clear)
      .foregroundColor(foregroundColor)
  }

  var foregroundColor: Color {
    isSelected ? .ds.text.brand.standard : .ds.text.neutral.standard
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

extension VerticalAlignment {
  private enum SelectionVerticalAlignment: AlignmentID {
    static func defaultValue(in d: ViewDimensions) -> CGFloat {
      return d[.bottom]
    }
  }

  static let selectionVerticalAlignment = VerticalAlignment(SelectionVerticalAlignment.self)
}

extension HorizontalAlignment {
  private enum SelectionHorizontalAlignment: AlignmentID {
    static func defaultValue(in d: ViewDimensions) -> CGFloat {
      return d[.leading]
    }
  }

  static let selectionHorizontalAlignment = HorizontalAlignment(SelectionHorizontalAlignment.self)
}

extension Alignment {
  static let selectionAlignment = Alignment(
    horizontal: .selectionHorizontalAlignment, vertical: .selectionVerticalAlignment)
}

#Preview {
  FiltersView(activeFilter: .constant(nil))
}
