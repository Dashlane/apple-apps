import Foundation
import CorePasswords
import SwiftUI
import Combine
import DashlaneReportKit
import CorePersonalData
import CoreUserTracking
import DashTypes
import DashlaneAppKit
import CoreSettings
import UIDelight

enum PasswordGeneratorMode {
    enum StandaloneAction {
        case showHistory
        case createCredential(password: GeneratedPassword)
    }

    case standalone((StandaloneAction) -> Void)
    case selection(_ credential: Credential, (GeneratedPassword) -> Void)
}

class PasswordGeneratorViewModel: ObservableObject {
    let mode: PasswordGeneratorMode

    @Published
    var password: String = ""

    @Published
    var passwordStrength: PasswordStrength = .veryUnguessable

    @Published
    var preferences: PasswordGeneratorPreferences

    var generator: PasswordGenerator

    @Published
    var pendingSaveAsCredentialPassword: GeneratedPassword?

    @Published
    var isDifferentFromDefaultConfiguration: Bool = false

    private var subscriptions = Set<AnyCancellable>()
    private let passwordEvaluator: PasswordEvaluatorProtocol
    private let usageLogService: UsageLogServiceProtocol
    private let sessionActivityReporter: ActivityReporterProtocol
    private let pasteboardService: PasteboardService
    private let userSettings: UserSettings
    private let saveGeneratedPassword: (GeneratedPassword) -> GeneratedPassword
    private var lastPersistedPassword: GeneratedPassword?
    private let savePreferencesOnChange: Bool
    
    init(mode: PasswordGeneratorMode,
         saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
         passwordEvaluator: PasswordEvaluatorProtocol,
         usageLogService: UsageLogServiceProtocol,
         sessionActivityReporter: ActivityReporterProtocol,
         userSettings: UserSettings,
         savePreferencesOnChange: Bool = true) {
        self.mode = mode
        self.saveGeneratedPassword = saveGeneratedPassword
        self.passwordEvaluator = passwordEvaluator
        self.usageLogService = usageLogService
        self.sessionActivityReporter = sessionActivityReporter
        self.pasteboardService = PasteboardService(userSettings: userSettings)
        self.userSettings = userSettings
        let preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
        self.preferences = preferences
        self.savePreferencesOnChange = savePreferencesOnChange
        self.generator = PasswordGenerator(preferences: preferences)
        configureRefresh()
    }
    
    convenience init(mode: PasswordGeneratorMode,
                     database: ApplicationDatabase,
                     passwordEvaluator: PasswordEvaluatorProtocol,
                     usageLogService: UsageLogServiceProtocol,
                     sessionActivityReporter: ActivityReporterProtocol,
                     userSettings: UserSettings,
                     savePreferencesOnChange: Bool = true) {
        self.init(mode: mode,
                  saveGeneratedPassword: { (try? database.save($0)) ?? $0 },
                  passwordEvaluator: passwordEvaluator,
                  usageLogService: usageLogService,
                  sessionActivityReporter: sessionActivityReporter,
                  userSettings: userSettings,
                  savePreferencesOnChange: savePreferencesOnChange)
    }
    
    convenience init(mode: PasswordGeneratorMode,
                     database: ApplicationDatabase,
                     passwordEvaluator: PasswordEvaluatorProtocol,
                     usageLogService: UsageLogServiceProtocol,
                     sessionActivityReporter: ActivityReporterProtocol,
                     userSettings: UserSettings) {
        self.init(mode: mode,
                  database: database,
                  passwordEvaluator: passwordEvaluator,
                  usageLogService: usageLogService,
                  sessionActivityReporter: sessionActivityReporter,
                  userSettings: userSettings,
                  savePreferencesOnChange: true)
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
    
    func savePreferences() {
        self.userSettings[.passwordGeneratorPreferences] = preferences
        self.isDifferentFromDefaultConfiguration = false
    }

    func refreshPreferences() {
        preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
        self.isDifferentFromDefaultConfiguration = false
    }
    
    func refresh() {
        self.generatePassword()
    }

    private func generatePassword() {
        password = generator.generate()
        let newPasswordStrength = passwordEvaluator.evaluate(password).strength
        passwordStrength = newPasswordStrength
        sessionActivityReporter.reportGeneratedPassword(with: preferences)
        accessibilityNotificationPasswordRefreshed()
    }

    private func accessibilityNotificationPasswordRefreshed() {
        let message: String = [L10n.Localizable.accessibilityGeneratedPasswordRefreshed, passwordStrength.funFact]
            .compactMap { $0 }
            .joined(separator: "\n")
        #if canImport(UIKit)
        UIAccessibility.fiberPost(.announcement, argument: message)
        #elseif canImport(AppKit)
        NSAccessibility.fiberPost(notification: message)
        #endif
    }

    private func copy() {
        pasteboardService.set(password)
        usageLogService.post(UsageLogCode75GeneralActions(type: "passwordGenerator", action: "copy"))
    }

        func performMainAction() {
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
            persistedPassword.platform = System.platform
            persistedPassword = saveGeneratedPassword(persistedPassword)
            lastPersistedPassword = persistedPassword
        }

        pendingSaveAsCredentialPassword = persistedPassword

        switch mode {
            case .standalone:
                copy()
            case let .selection(_ , action):
                action(persistedPassword)
        }

        if case let .selection(credential, _) = self.mode, let domain = credential.url?.displayDomain {
            self.usageLogService.post(UsageLogCode7GeneratedPassword(website: domain))
        }
    }

    func didViewPasswordGenerator() {
        usageLogService.post(UsageLogCode34UserNavigation(viewName: "KWPasswordGeneratorViewController"))
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

extension GeneratedPassword {
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

extension PasswordGenerator {
    init(preferences: PasswordGeneratorPreferences) {
        let composition = PasswordCompositionOptions(shouldContainsDigits: preferences.shouldContainDigits,
                                                     shouldContainsLetters: preferences.shouldContainLetters,
                                                     shouldContainsSymbols: preferences.shouldContainSymbols)

        self.init(length: preferences.length,
                  composition: composition,
                  distinguishable: !preferences.allowSimilarCharacters)
    }
}

extension PasswordGeneratorViewModel {
    static var mock: PasswordGeneratorViewModel {
        PasswordGeneratorViewModel(
            mode: .standalone({ _ in }),
            saveGeneratedPassword: { return $0 },
            passwordEvaluator: PasswordEvaluatorMock(),
            usageLogService: UsageLogService.fakeService,
            sessionActivityReporter: .fake,
            userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore()))
    }
}


