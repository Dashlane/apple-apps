import SwiftUI
import Combine
import CorePersonalData
import CoreUserTracking
import VaultKit
import CoreLocalization

struct FiltersView: View {
    @Binding
    var activeFilter: VaultItemsSection

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(VaultItemsSection.allCases) { vaultListFilter in
                    Button(vaultListFilter.title) {
                        self.activeFilter = vaultListFilter
                    }
                    .buttonStyle(FilterButtonStyle(isSelected: vaultListFilter == self.activeFilter))
                    .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityTraitTab(vaultListFilter.title)))
                    .fiberAccessibilityAddTraits(vaultListFilter == self.activeFilter ? .isSelected : [])

                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 10)
        .background(Color.clear)
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
        if isSelected {
            return .ds.container.expressive.neutral.catchy.active
        } else {
            return .ds.container.expressive.neutral.quiet.idle
        }
    }

    var foregroundColor: Color {
        if isSelected {
            return .ds.text.inverse.catchy
        } else {
            return .ds.text.neutral.standard
        }
    }
}

extension VaultItemsSection {
   var title: String {
       switch category {
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
       }
   }
}
