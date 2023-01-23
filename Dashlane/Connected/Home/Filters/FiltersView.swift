import SwiftUI
import Combine
import CorePersonalData
import CoreUserTracking

enum VaultListFilter: CaseIterable, Identifiable, Equatable {
    case all
    case credentials
    case secureNotes
    case payments
    case personalInfo
    case ids

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            return L10n.Localizable.itemsTitle
        case .credentials:
            return L10n.Localizable.mainMenuLoginsAndPasswords
        case .secureNotes:
            return L10n.Localizable.mainMenuNotes
        case .payments:
            return L10n.Localizable.mainMenuPayment
        case .personalInfo:
            return L10n.Localizable.mainMenuContact
        case .ids:
            return L10n.Localizable.mainMenuIDs
        }
    }
}

struct FiltersView: View {
    @Binding
    var activeFilter: VaultListFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(VaultListFilter.allCases) { vaultListFilter in
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

extension ItemCategory {
    var vaultListFilter: VaultListFilter {
        switch self {
        case .credentials:
            return .credentials
        case .ids:
            return .ids
        case .payments:
            return .payments
        case .personalInfo:
            return .personalInfo
        case .secureNotes:
            return .secureNotes
        }
    }
}
