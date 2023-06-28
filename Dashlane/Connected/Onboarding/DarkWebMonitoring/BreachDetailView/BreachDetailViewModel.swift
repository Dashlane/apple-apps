import Foundation
import DomainParser
import CorePersonalData
import DashlaneAppKit
import CoreSettings
import DashTypes
import VaultKit

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
    var currentConfiguration: BreachDetailViewConfiguration

    lazy var miniBrowserViewModel: MiniBrowserViewModel? = {
        guard let url = changePasswordURL else {
            return nil
        }

        return MiniBrowserViewModel(email: email, password: password, displayableDomain: domain, url: url, domainParser: domainParser, userSettings: userSettings) { [weak self] result in
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
    private let userSettings: UserSettings
    private var initialConfiguration: BreachDetailViewConfiguration
    private let dwmOnboardingService: DWMOnboardingService

    init(breach: DWMSimplifiedBreach,
         email: String,
         domainParser: DomainParser,
         vaultItemsService: VaultItemsServiceProtocol,
         dwmOnboardingService: DWMOnboardingService,
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
            return
        }

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

        }
    }

    func changePassword() {
        guard changePasswordURL != nil else {
            return
        }
        shouldShowMiniBrowser = true
    }

    func newPasswordToBeSaved() {
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
