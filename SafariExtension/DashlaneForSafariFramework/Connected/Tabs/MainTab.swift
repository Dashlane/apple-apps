import Foundation

enum MainTab: TabViewElement {
    case vault(VaultViewModel)
    case autofill(AutofillTabViewModel)
    case passwordGenerator(PasswordGeneratorTabViewModel)
    case other(MoreTabViewModel)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.vault, .vault): return true
        case (.autofill, .autofill): return true
        case (.passwordGenerator, .passwordGenerator): return true
        case (.other, .other): return true
        default:
            return false
        }
    }

        var activable: TabActivable? {
        switch self {
        case let .vault(viewModel):
            return viewModel
        case let .autofill(viewModel):
            return viewModel
        case let .passwordGenerator(viewModel):
            return viewModel
        default: return nil
        }
    }
    

    var isActive: Bool {
        activable?.isActive.value ?? true
    }
    
}

extension MainTab {
    var distributedSizePercentage: CGFloat {
        switch self {
        case .other:
            return 20
        default:
            return 80/3
        }
    }
    
    var title: String? {
        switch self {
        case .vault: return L10n.Localizable.safariTabVault
        case .autofill: return L10n.Localizable.safariTabAutofill
        case .passwordGenerator: return L10n.Localizable.safariTabGenerator
        case .other: return nil
        }
    }
    
    var image: ImageAsset {
        switch self {
        case .vault: return Asset.tabVault
        case .autofill: return Asset.tabAutofill
        case .passwordGenerator: return Asset.tabPasswordGenerator
        case .other: return Asset.tabSettings
        }
    }
}
