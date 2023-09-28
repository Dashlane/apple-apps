import Foundation
import CorePasswords
import SwiftUI
import Combine
import CorePersonalData
import CoreUserTracking
import DashTypes
import CoreSettings
import UIDelight
import CoreLocalization

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

    private var subscriptions = Set<AnyCancellable>()
    private let passwordEvaluator: PasswordEvaluatorProtocol
    private let sessionActivityReporter: ActivityReporterProtocol
    private let userSettings: UserSettings
    private let saveGeneratedPassword: (GeneratedPassword) -> GeneratedPassword
    private var lastPersistedPassword: GeneratedPassword?
    private let savePreferencesOnChange: Bool
    private let copyAction: ((String) -> Void)

    public init(mode: PasswordGeneratorMode,
                saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
                passwordEvaluator: PasswordEvaluatorProtocol,
                sessionActivityReporter: ActivityReporterProtocol,
                userSettings: UserSettings,
                savePreferencesOnChange: Bool = true,
                copyAction: @escaping ((String) -> Void)) {
        self.mode = mode
        self.saveGeneratedPassword = saveGeneratedPassword
        self.passwordEvaluator = passwordEvaluator
        self.sessionActivityReporter = sessionActivityReporter
        self.userSettings = userSettings
        let preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
        self.preferences = preferences
        self.savePreferencesOnChange = savePreferencesOnChange
        self.copyAction = copyAction
        self.generator = PasswordGenerator(preferences: preferences)
        configureRefresh()
    }

    public convenience init(mode: PasswordGeneratorMode,
                            database: ApplicationDatabase,
                            passwordEvaluator: PasswordEvaluatorProtocol,
                            sessionActivityReporter: ActivityReporterProtocol,
                            userSettings: UserSettings,
                            savePreferencesOnChange: Bool = true,
                            copyAction: @escaping ((String) -> Void)) {
        self.init(mode: mode,
                  saveGeneratedPassword: { (try? database.save($0)) ?? $0 },
                  passwordEvaluator: passwordEvaluator,
                  sessionActivityReporter: sessionActivityReporter,
                  userSettings: userSettings,
                  savePreferencesOnChange: savePreferencesOnChange,
                  copyAction: copyAction)
    }

    public convenience init(mode: PasswordGeneratorMode,
                            database: ApplicationDatabase,
                            passwordEvaluator: PasswordEvaluatorProtocol,
                            sessionActivityReporter: ActivityReporterProtocol,
                            userSettings: UserSettings,
                            copyAction: @escaping ((String) -> Void)) {
        self.init(mode: mode,
                  database: database,
                  passwordEvaluator: passwordEvaluator,
                  sessionActivityReporter: sessionActivityReporter,
                  userSettings: userSettings,
                  savePreferencesOnChange: true,
                  copyAction: copyAction)
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
                self.isDifferentFromDefaultConfiguration = self.userSettings[.passwordGeneratorPreferences] != preferences
                if self.savePreferencesOnChange {
                    self.userSettings[.passwordGeneratorPreferences] = preferences
                }
                self.generator = PasswordGenerator(preferences: preferences)
                self.generatePassword()
            }.store(in: &subscriptions)
    }

    public func savePreferences() {
        self.userSettings[.passwordGeneratorPreferences] = preferences
        self.isDifferentFromDefaultConfiguration = false
    }

    public func refreshPreferences() {
        preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
        self.isDifferentFromDefaultConfiguration = false
    }

    public func refresh() {
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
        let message: String = [L10n.Core.accessibilityGeneratedPasswordRefreshed, passwordStrength.funFact]
            .compactMap { $0 }
            .joined(separator: "\n")
        #if canImport(UIKit)
        UIAccessibility.fiberPost(.announcement, argument: message)
        #elseif canImport(AppKit)
        NSAccessibility.fiberPost(notification: message)
        #endif
    }

    private func copy() {
        copyAction(password)
    }

        public func performMainAction() {
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

public extension PasswordStrength {
    var funFact: String {
        switch self {
            case .veryGuessable:
                return L10n.Core.passwordGeneratorStrengthVeryGuessabble
            case .tooGuessable:
                return  L10n.Core.passwordGeneratorStrengthTooGuessable
            case .somewhatGuessable:
                return  L10n.Core.passwordGeneratorStrengthSomewhatGuessable
            case .safelyUnguessable:
                return  L10n.Core.passwordGeneratorStrengthSafelyUnguessable
            case .veryUnguessable:
                return  L10n.Core.passwordGeneratorStrengthVeryUnguessable
        }
    }
}

private extension PasswordCompositionOptions {
    init(shouldContainsDigits: Bool, shouldContainsLetters: Bool, shouldContainsSymbols: Bool) {
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

public extension GeneratedPassword {
    mutating func link(to credential: Credential) {
        if !credential.metadata.id.isTemporary {
            authId = credential.id
        }
        domain = credential.url
    }
}

private extension ActivityReporterProtocol {
    func reportGeneratedPassword(with preferences: PasswordGeneratorPreferences) {
        let event = UserEvent.GeneratePassword(hasDigits: preferences.shouldContainDigits,
                                               hasLetters: preferences.shouldContainLetters,
                                               hasSimilar: preferences.allowSimilarCharacters,
                                               hasSymbols: preferences.shouldContainSymbols,
                                               length: Int(preferences.length))
        report(event)
    }
}

public extension PasswordGenerator {
    init(preferences: PasswordGeneratorPreferences) {
        let composition = PasswordCompositionOptions(shouldContainsDigits: preferences.shouldContainDigits,
                                                     shouldContainsLetters: preferences.shouldContainLetters,
                                                     shouldContainsSymbols: preferences.shouldContainSymbols)

        self.init(length: preferences.length,
                  composition: composition,
                  distinguishable: !preferences.allowSimilarCharacters)
    }
}

public extension PasswordGeneratorViewModel {
    static var mock: PasswordGeneratorViewModel {
        PasswordGeneratorViewModel(
            mode: .standalone({ _ in }),
            saveGeneratedPassword: { return $0 },
            passwordEvaluator: .mock(),
            sessionActivityReporter: .fake,
            userSettings: UserSettings(internalStore: .mock()),
            copyAction: {_ in })
    }
}
