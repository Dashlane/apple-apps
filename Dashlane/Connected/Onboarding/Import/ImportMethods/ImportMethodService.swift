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
    return [bestImportMethods(), otherImportMethods()]
      .compactMap { $0 }
      .map { ImportMethodSection(section: ($0.0, $0.1)) }
  }

  private let featureService: FeatureServiceProtocol

  init(featureService: FeatureServiceProtocol, mode: ImportMethodMode) {
    self.featureService = featureService
    self.mode = mode
  }

  private func bestImportMethods() -> (String, [LegacyImportMethod])? {
    return (L10n.Localizable.guidedOnboardingImportMethodBest, [.manual])
  }

  private func otherImportMethods() -> (String, [LegacyImportMethod]) {
    var methods: [LegacyImportMethod] = []
    methods.append(.chrome)
    if featureService.isEnabled(.dashImport) {
      methods.append(.dash)
    }
    if featureService.isEnabled(.keychainImport) {
      methods.append(.keychainCSV)
    } else {
      methods.append(.keychain)
    }
    return (L10n.Localizable.guidedOnboardingImportMethodOther, methods)
  }
}

extension ImportMethodService {
  static func mock(for mode: ImportMethodMode) -> ImportMethodService {
    return .init(featureService: .mock(), mode: mode)
  }
}
