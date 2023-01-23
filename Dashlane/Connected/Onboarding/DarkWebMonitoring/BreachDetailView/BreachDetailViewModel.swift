import Foundation
import DomainParser
import CorePersonalData
import DashlaneAppKit
import CoreSettings
import DashTypes

enum BreachDetailViewConfiguration: Hashable {
    case passwordFound
    case passwordNotFound(eventDate: Date?)
    case newPasswordToBeSaved
    case itemSaved
}

protocol BreachDetailViewModelProtocol: ObservableObject {
    var shouldShowMiniBrowser: Bool { get set }
    var title: String { get set }
    var email: String { get set }
    var password: String { get set }
    var website: String { get set }
    var currentConfiguration: BreachDetailViewConfiguration { get set }
    var shouldRevealPassword: Bool { get set }
    var isPasswordFieldFocused: Bool { get set }
    var canSave: Bool { get }
    var miniBrowserViewModel: MiniBrowserViewModel? { get }

    func logDisplay()
    func cancel()
    func save()
    func changePassword()
    func newPasswordToBeSaved()
}

class BreachDetailViewModel: BreachDetailViewModelProtocol, SessionServicesInjecting {

    enum Completion {
        case cancel
    }

    var title: String
    var email: String
    let initialPassword: String
    var website: String
    let domain: String
    var changePasswordURL: URL?
    var leakDate: Date?
    let domainParser: DomainParser
    var completion: (Completion) -> Void

    var canSave: Bool {
        if currentConfiguration == .newPasswordToBeSaved {
            return !password.isEmpty
        }

        return initialPassword != password
    }

    @Published
    var password: String

    @Published
    var shouldRevealPassword: Bool = false

    @Published
    var shouldShowMiniBrowser: Bool = false

    @Published
    var isPasswordFieldFocused: Bool = false

    @Published
    var currentConfiguration: BreachDetailViewConfiguration {
        didSet {
            if oldValue != currentConfiguration {
                switch currentConfiguration {
                case .newPasswordToBeSaved:
                    usageLogService.log(.savingNewPasswordDisplayed(domain: breach.url.displayDomain))
                case .itemSaved:
                    usageLogService.log(.securedItemSavedConfirmationDisplayed(domain: breach.url.displayDomain))
                default:
                    break
                }
            }
        }
    }

    lazy var miniBrowserViewModel: MiniBrowserViewModel? = {
        guard let url = changePasswordURL else {
            return nil
        }

        return MiniBrowserViewModel(email: email, password: password, displayableDomain: domain, url: url, domainParser: domainParser, usageLogService: usageLogService, userSettings: userSettings) { [weak self] result in
            switch result {
            case .back, .done:
                self?.shouldShowMiniBrowser = false
                if self?.initialPassword != self?.password {
                    self?.newPasswordToBeSaved()
                }
            case .generatedPasswordCopiedToClipboard(let password):
                self?.password = password
            }
        }
    }()

    private let breach: DWMSimplifiedBreach
    private let vaultItemsService: VaultItemsServiceProtocol
    private let usageLogService: DWMLogService
    private let userSettings: UserSettings
    private var initialConfiguration: BreachDetailViewConfiguration
    private let dwmOnboardingService: DWMOnboardingService

    init(breach: DWMSimplifiedBreach,
         email: String,
         domainParser: DomainParser,
         vaultItemsService: VaultItemsServiceProtocol,
         dwmOnboardingService: DWMOnboardingService,
         usageLogService: UsageLogServiceProtocol,
         userSettings: UserSettings,
         completion: @escaping (BreachDetailViewModel.Completion) -> Void) {
        self.vaultItemsService = vaultItemsService
        self.dwmOnboardingService = dwmOnboardingService
        self.breach = breach
        self.title = breach.url.displayDomain
        self.domain = breach.url.displayDomain
        self.email = email
        self.initialPassword = breach.leakedPassword ?? ""
        self.password = breach.leakedPassword ?? ""
        self.website = breach.url.openableURL?.absoluteString ?? ""
        self.changePasswordURL = breach.url.openableURL
        self.leakDate = breach.date
        self.domainParser = domainParser
        self.completion = completion
        self.usageLogService = usageLogService.dwmLogService
        self.userSettings = userSettings

        let configuration: BreachDetailViewConfiguration = {
            guard let leakedPassword = breach.leakedPassword, !leakedPassword.isEmpty else {
              return .passwordNotFound(eventDate: breach.date)
            }
            return .passwordFound
        }()

        self.initialConfiguration = configuration
        self.currentConfiguration = configuration
    }

    func logDisplay() {
        usageLogService.log(.breachDetailViewDisplayed(passwordFound: breach.leakedPassword != nil, domain: breach.url.displayDomain))
    }

    func cancel() {
        switch currentConfiguration {
        case .passwordFound, .passwordNotFound, .itemSaved:
            completion(.cancel)
        case .newPasswordToBeSaved:
            currentConfiguration = initialConfiguration
        }

    }

    func save() {
                guard currentConfiguration != .itemSaved else {
            completion(.cancel)
            return
        }

        guard canSave else {
            usageLogService.log(.securedItemSaveTapped(disabled: true))
            return
        }

        usageLogService.log(.securedItemSaveTapped(disabled: false))

        var credential = Credential()
        credential.anonId = UUID().uuidString
        credential.email = email
        credential.editableURL = website
        credential.password = password
        credential.prepareForSaving()

        do {
            try credential.validate()
            let now = Date()
            credential.creationDatetime = now
            credential.userModificationDatetime = now
            credential.passwordModificationDate = now
            let item = try vaultItemsService.save(credential)
            dwmOnboardingService.itemSavedToVault(item, for: breach)
            itemSaved()
        } catch {
            usageLogService.log(.itemCannotBeSavedError)
        }
    }

    func changePassword() {
        usageLogService.log(.changePasswordTapped(domain: breach.url.displayDomain))

        guard changePasswordURL != nil else {
            usageLogService.log(.miniBrowserCannotBeOpenedError)
            return
        }

        shouldShowMiniBrowser = true
        usageLogService.log(.miniBrowserDisplayed(domain: breach.url.displayDomain))
    }

    func newPasswordToBeSaved() {
        usageLogService.log(.manualChangeStarted(domain: breach.url.displayDomain))
        currentConfiguration = .newPasswordToBeSaved
        shouldRevealPassword = true
        isPasswordFieldFocused = true
    }

    private func itemSaved() {
        currentConfiguration = .itemSaved
        shouldRevealPassword = false
        isPasswordFieldFocused = false
    }
}
