import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import SwiftUI
import UserTrackingFoundation

public struct FiltersView: View {
  @Binding var activeFilter: ItemCategory?

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  let enabledFilters: [ItemCategory]

  public init(activeFilter: Binding<ItemCategory?>, enabledFilters: [ItemCategory]) {
    self._activeFilter = activeFilter
    self.enabledFilters = enabledFilters
  }

  public var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        ZStack(alignment: .selectionAlignment) {
          selectionBackground()
            .alignmentGuide(
              .selectionHorizontalAlignment, computeValue: { d in d[HorizontalAlignment.center] })

          HStack(alignment: .center, spacing: 0) {
            filterButton(for: nil, scrollProxy: proxy)
              .id("")

            ForEach(enabledFilters) { filter in
              filterButton(for: filter, scrollProxy: proxy)
                .id(filter)
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
  }

  private func filterButton(for filter: ItemCategory?, scrollProxy: ScrollViewProxy) -> some View {
    Group {
      if filter == activeFilter {
        Button(filter.title) {}
          .alignmentGuide(
            .selectionHorizontalAlignment, computeValue: { d in d[HorizontalAlignment.center] })
      } else {
        Button(filter.title) {
          select(filter, scrollProxy: scrollProxy)
        }
        .simultaneousGesture(
          TapGesture()
            .onEnded { _ in
              select(filter, scrollProxy: scrollProxy)
            })
      }
    }
    .buttonStyle(FilterButtonStyle(isSelected: filter == activeFilter))
    .fiberAccessibilityLabel(Text(L10n.Core.accessibilityTraitTab(filter.title)))
    .fiberAccessibilityAddTraits(filter == activeFilter ? .isSelected : [])
  }

  private func select(_ filter: ItemCategory?, scrollProxy: ScrollViewProxy) {
    guard activeFilter != filter else { return }
    withAnimation(.snappy(duration: 0.3)) {
      activeFilter = filter
      if let filter {
        scrollProxy.scrollTo(filter)
      } else {
        scrollProxy.scrollTo("")
      }
    }
  }

  private func selectionBackground() -> some View {
    Text(activeFilter.title)
      .textStyle(.component.button.small)
      .padding(.vertical, 6)
      .padding(.horizontal, 10)
      .foregroundStyle(.clear)
      .background {
        RoundedRectangle(cornerRadius: 7)
          .foregroundStyle(Color.ds.container.agnostic.neutral.supershy)
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
      .contentShape(Rectangle())
      .foregroundStyle(foregroundColor)
  }

  var foregroundColor: Color {
    isSelected ? .ds.text.brand.standard : .ds.text.neutral.standard
  }
}

extension ItemCategory? {
  var title: String {
    switch self {
    case nil:
      return CoreL10n.itemsTitle
    case .credentials:
      return CoreL10n.mainMenuLoginsAndPasswords
    case .secureNotes:
      return CoreL10n.mainMenuNotes
    case .payments:
      return CoreL10n.mainMenuPayment
    case .personalInfo:
      return CoreL10n.mainMenuContact
    case .ids:
      return CoreL10n.mainMenuIDs
    case .secrets:
      return CoreL10n.mainMenuSecrets
    case .wifi:
      return CoreL10n.WiFi.mainMenu
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
  FiltersView(activeFilter: .constant(nil), enabledFilters: ItemCategory.allCases)
}
