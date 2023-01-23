import SwiftUI
import CorePasswords

extension Color {
    init(passwordStrength: PasswordStrength) {
        switch passwordStrength.score {
        case 0..<2:
            self = Color(asset: SharedAsset.errorRed)
        case 2..<3:
            self = Color(asset: SharedAsset.yellow)
        default:
            self = Color(asset: SharedAsset.validatorGreen)
        }
    }
}

extension L10n.Localizable {
    static func passwordDetailText(for passwordStrength: PasswordStrength) -> String {
        switch passwordStrength {
        case .tooGuessable:
            return L10n.Localizable.securityDashboardStrengthTrivial
        case .veryGuessable:
            return L10n.Localizable.securityDashboardStrengthWeak
        case .somewhatGuessable:
            return L10n.Localizable.kwPasswordNotSoSafe
        case .safelyUnguessable:
            return L10n.Localizable.kwPasswordSafe
        case .veryUnguessable:
            return L10n.Localizable.kwPasswordSuperSafe
        }
    }
}

extension PasswordStrength {
    var funFact: String {
        switch self {
            case .veryGuessable:
                return L10n.Localizable.passwordGeneratorStrengthVeryGuessabble
            case .tooGuessable:
                return  L10n.Localizable.passwordGeneratorStrengthTooGuessable
            case .somewhatGuessable:
                return  L10n.Localizable.passwordGeneratorStrengthSomewhatGuessable
            case .safelyUnguessable:
                return  L10n.Localizable.passwordGeneratorStrengthSafelyUnguessable
            case .veryUnguessable:
                return  L10n.Localizable.passwordGeneratorStrengthVeryUnguessable
        }
    }
}

extension ProgressBarView {
    init(passwordStrength: PasswordStrength,
         backgroundColor: Color = Color(asset: SharedAsset.fieldBackground)) {
        self.init(progress: CGFloat(passwordStrength.score) + 1,
                  total: 5,
                  fillColor: Color(passwordStrength: passwordStrength),
                  backgroundColor: backgroundColor)
    }
}

extension PrideProgressBarView {
    init(passwordStrength: PasswordStrength,
         backgroundColor: Color = Color(asset: SharedAsset.fieldBackground)) {
        self.init(progress: CGFloat(passwordStrength.score) + 1,
                  total: 5,
                  fillColor: Color(passwordStrength: passwordStrength),
                  backgroundColor: backgroundColor)
    }
}
