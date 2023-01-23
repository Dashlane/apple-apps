import DashlaneAppKit
import CoreFeature

enum ImportMethodMode: String {
    case firstPassword
    case browser
}

protocol ImportMethodServiceProtocol {
    var mode: ImportMethodMode { get }
    var methods: [ImportMethodSection] { get }
}

class ImportMethodService: ImportMethodServiceProtocol {

    let mode: ImportMethodMode

    var methods: [ImportMethodSection] {
        return [bestImportMethods(), fatestImportMethods(), otherImportMethods()]
            .compactMap { $0 }
            .map { ImportMethodSection(section: ($0.0, $0.1)) }
    }

    private let featureService: FeatureServiceProtocol

    init(featureService: FeatureServiceProtocol, mode: ImportMethodMode) {
        self.featureService = featureService
        self.mode = mode
    }

    private func bestImportMethods() -> (String, [ImportMethod])? {
        switch mode {
        case .firstPassword:
            return (L10n.Localizable.guidedOnboardingImportMethodBest, [.manual])
        case .browser:
            return nil
        }
    }

    private func fatestImportMethods() -> (String, [ImportMethod])? {
        switch mode {
        case .firstPassword:
            return nil
        case .browser:
            return (L10n.Localizable.guidedOnboardingImportMethodFastest, [.chrome])
        }
    }

    private func otherImportMethods() -> (String, [ImportMethod]) {
        var methods: [ImportMethod] = []
        switch mode {
        case .firstPassword:
            methods.append(.chrome)
            if featureService.isEnabled(.dashImport) {
                methods.append(.dash)
            }
            if featureService.isEnabled(.keychainImport) {
                methods.append(.keychainCSV)
            } else {
                methods.append(.keychain)
            }
        case .browser:
            if featureService.isEnabled(.dashImport) {
                methods.append(.dash)
            }
            if featureService.isEnabled(.keychainImport) {
                methods.append(.keychainCSV)
            } else {
                methods.append(.keychain)
            }
            methods.append(.manual)
        }
        return (L10n.Localizable.guidedOnboardingImportMethodOther, methods)
    }

}

extension ImportMethodService {
    static func mock(for mode: ImportMethodMode) -> ImportMethodService {
        return .init(featureService: .mock(), mode: mode)
    }
}
