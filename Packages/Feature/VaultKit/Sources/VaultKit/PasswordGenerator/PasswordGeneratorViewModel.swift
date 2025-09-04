import Combine
import CoreFeature
import CoreLocalization
import CorePasswords
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UIDelight
import UserTrackingFoundation

public enum PasswordGeneratorMode {
  public enum StandaloneAction {
    case showHistory
    case createCredential(password: GeneratedPassword)
  }

  case standalone((StandaloneAction) -> Void)
  case selection(_ credential: Credential, (GeneratedPassword) -> Void)
}

public class PasswordGeneratorViewModel: ObservableObject {
  let mode: PasswordGeneratorMode

  @Published
  var password: String = ""

  @Published
  var passwordStrength: PasswordStrength = .veryUnguessable

  @Published
  public var preferences: PasswordGeneratorPreferences

  var generator: PasswordGenerator

  @Published
  var pendingSaveAsCredentialPassword: GeneratedPassword?

  @Published
  public var isDifferentFromDefaultConfiguration: Bool = false

  @Published
  private var vaultState: VaultState = .default

  private var subscriptions = Set<AnyCancellable>()
  private let passwordEvaluator: PasswordEvaluatorProtocol
  private let sessionActivityReporter: ActivityReporterProtocol
  private let userSettings: UserSettings
  private let vaultStateService: VaultStateServiceProtocol
  private let deeplinkingService: DeepLinkingServiceProtocol
  private let saveGeneratedPassword: (GeneratedPassword) -> GeneratedPassword
  private var lastPersistedPassword: GeneratedPassword?
  private let savePreferencesOnChange: Bool
  private let pasteboardService: PasteboardServiceProtocol

  public init(
    mode: PasswordGeneratorMode,
    saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
    passwordEvaluator: PasswordEvaluatorProtocol,
    sessionActivityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    savePreferencesOnChange: Bool = true,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.mode = mode
    self.saveGeneratedPassword = saveGeneratedPassword
    self.passwordEvaluator = passwordEvaluator
    self.sessionActivityReporter = sessionActivityReporter
    self.userSettings = userSettings
    self.vaultStateService = vaultStateService
    self.deeplinkingService = deeplinkingService
    let preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
    self.preferences = preferences
    self.savePreferencesOnChange = savePreferencesOnChange
    self.pasteboardService = pasteboardService
    self.generator = PasswordGenerator(preferences: preferences)
    configureRefresh()
  }

  public convenience init(
    mode: PasswordGeneratorMode,
    database: ApplicationDatabase,
    passwordEvaluator: PasswordEvaluatorProtocol,
    sessionActivityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    savePreferencesOnChange: Bool = true,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.init(
      mode: mode,
      saveGeneratedPassword: { (try? database.save($0)) ?? $0 },
      passwordEvaluator: passwordEvaluator,
      sessionActivityReporter: sessionActivityReporter,
      userSettings: userSettings,
      vaultStateService: vaultStateService,
      deeplinkingService: deeplinkingService,
      savePreferencesOnChange: savePreferencesOnChange,
      pasteboardService: pasteboardService)
  }

  public convenience init(
    mode: PasswordGeneratorMode,
    database: ApplicationDatabase,
    passwordEvaluator: PasswordEvaluatorProtocol,
    sessionActivityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.init(
      mode: mode,
      database: database,
      passwordEvaluator: passwordEvaluator,
      sessionActivityReporter: sessionActivityReporter,
      userSettings: userSettings,
      vaultStateService: vaultStateService,
      deeplinkingService: deeplinkingService,
      savePreferencesOnChange: true,
      pasteboardService: pasteboardService)
  }

  private func configureRefresh() {
    $preferences
      .dropFirst()
      .removeDuplicates()
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { [weak self] preferences in
        guard let self = self else {
          return
        }
        self.isDifferentFromDefaultConfiguration =
          self.userSettings[.passwordGeneratorPreferences] != preferences
        if self.savePreferencesOnChange {
          self.userSettings[.passwordGeneratorPreferences] = preferences
        }
        self.generator = PasswordGenerator(preferences: preferences)
        self.generatePassword()
      }.store(in: &subscriptions)

    vaultStateService
      .vaultStatePublisher()
      .assign(to: &$vaultState)
  }

  public func savePreferences() {
    self.userSettings[.passwordGeneratorPreferences] = preferences
    self.isDifferentFromDefaultConfiguration = false
  }

  public func refreshPreferences() {
    preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
    self.isDifferentFromDefaultConfiguration = false
  }

  public func forcedRefresh() {
    self.generatePassword()
  }

  public func refresh() {
    guard vaultState != .frozen else {
      return
    }
    self.generatePassword()
  }

  private func generatePassword() {
    password = generator.generate()
    let newPasswordStrength = passwordEvaluator.evaluate(password)
    passwordStrength = newPasswordStrength
    sessionActivityReporter.reportGeneratedPassword(with: preferences)
    accessibilityNotificationPasswordRefreshed()
  }

  private func accessibilityNotificationPasswordRefreshed() {
    let message: String = [
      CoreL10n.accessibilityGeneratedPasswordRefreshed, passwordStrength.funFact,
    ]
    .compactMap { $0 }
    .joined(separator: "\n")
    UIAccessibility.fiberPost(.announcement, argument: message)
  }

  private func copy() {
    pasteboardService.copy(password)
  }

  public func performMainAction() {
    guard vaultState != .frozen else {
      deeplinkingService.handle(.frozenAccount)
      return
    }

    var persistedPassword: GeneratedPassword
    if let last = lastPersistedPassword, password == last.password {
      persistedPassword = last
    } else {
      persistedPassword = GeneratedPassword()
      persistedPassword.generatedDate = Date()
      if case let .selection(credential, _) = mode {
        persistedPassword.link(to: credential)
      }
      persistedPassword.password = self.password
      persistedPassword.platform = Platform.passwordManager.rawValue
      persistedPassword = saveGeneratedPassword(persistedPassword)
      lastPersistedPassword = persistedPassword
    }

    pendingSaveAsCredentialPassword = persistedPassword

    switch mode {
    case .standalone:
      copy()
    case let .selection(_, action):
      action(persistedPassword)
    }
  }
}

extension PasswordStrength {
  public var funFact: String {
    switch self {
    case .veryGuessable:
      return CoreL10n.passwordGeneratorStrengthVeryGuessabble
    case .tooGuessable:
      return CoreL10n.passwordGeneratorStrengthTooGuessable
    case .somewhatGuessable:
      return CoreL10n.passwordGeneratorStrengthSomewhatGuessable
    case .safelyUnguessable:
      return CoreL10n.passwordGeneratorStrengthSafelyUnguessable
    case .veryUnguessable:
      return CoreL10n.passwordGeneratorStrengthVeryUnguessable
    }
  }
}

extension PasswordCompositionOptions {
  fileprivate init(
    shouldContainsDigits: Bool, shouldContainsLetters: Bool, shouldContainsSymbols: Bool
  ) {
    var options: PasswordCompositionOptions = []
    if shouldContainsDigits {
      options.insert(.numerals)
    }
    if shouldContainsLetters {
      options.insert([.lowerCaseLetters, .upperCaseLetters])
    }
    if shouldContainsSymbols {
      options.insert([.symbols])
    }
    self = options
  }
}

extension GeneratedPassword {
  public mutating func link(to credential: Credential) {
    if !credential.metadata.id.isTemporary {
      authId = credential.id
    }
    domain = credential.url
  }
}

extension ActivityReporterProtocol {
  fileprivate func reportGeneratedPassword(with preferences: PasswordGeneratorPreferences) {
    let event = UserEvent.GeneratePassword(
      hasDigits: preferences.shouldContainDigits,
      hasLetters: preferences.shouldContainLetters,
      hasSimilar: preferences.allowSimilarCharacters,
      hasSymbols: preferences.shouldContainSymbols,
      length: Int(preferences.length))
    report(event)
  }
}

extension PasswordGenerator {
  public init(preferences: PasswordGeneratorPreferences) {
    let composition = PasswordCompositionOptions(
      shouldContainsDigits: preferences.shouldContainDigits,
      shouldContainsLetters: preferences.shouldContainLetters,
      shouldContainsSymbols: preferences.shouldContainSymbols)

    self.init(
      length: preferences.length,
      composition: composition,
      distinguishable: !preferences.allowSimilarCharacters)
  }
}

extension PasswordGeneratorViewModel {
  public static var mock: PasswordGeneratorViewModel {
    PasswordGeneratorViewModel(
      mode: .standalone({ _ in }),
      saveGeneratedPassword: { return $0 },
      passwordEvaluator: .mock(),
      sessionActivityReporter: .mock,
      userSettings: UserSettings(internalStore: .mock()),
      vaultStateService: .mock(),
      deeplinkingService: MockVaultKitServicesContainer().deeplinkService,
      pasteboardService: .mock())
  }
}
