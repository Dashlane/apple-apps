import Foundation
import DomainParser
import SafariServices.SFSafariApplication
import Combine
import DashlaneAppKit
import CoreSettings

class AutofillViewModel: ObservableObject, TabActivable {
    
    @Published var pageTitle: String = ""

    @Published var domainTitle: String = "" {
        willSet {
            if showDisableWebsiteConfirmationAlert {
                revertActiveValue()
            }
        }
    }
    @Published var pageDisabled: Bool = false
    @Published var viewDisabled: Bool = false {
        didSet {
            if viewDisabled != oldValue {
                self.getCurrentURL()
            }
        }
    }
    
    @Published var activeValue: AutofillPolicy.Policy {
        didSet {
            changePolicyWithConfirmation(value: activeValue, for: activeLevel, previousValue: oldValue)
        }
    }

    var previousActiveValue: AutofillPolicy.Policy?

    @Published var activeLevel: AutofillPolicy.Level {
        didSet {
            updateActiveValue()
            disablePageChoicesIfNeeded()
            
            if self.activeLevel == .page && self.activeValue == .everything && preferences.policy(forDomain: domainTitle)?.policy == .loginPasswordsOnly {
                self.activeValue = .loginPasswordsOnly
                saveSecuredData()
            }
            findPreferences()
        }
    }

    @Published
    var disabledFields = Set<UserDefinedRule>()

    @Published
    var showDisableWebsiteConfirmationAlert: Bool = false

    func pageAutofillPolicy() -> AutofillPolicy? {
        preferences.policy(forPage: pageTitle)
    }
    
    func domainAutofillPolicy() -> AutofillPolicy? {
        preferences.policy(forDomain: domainTitle)
    }
    
    let userEncryptedSettings: UserEncryptedSettings
    let domainParser: DomainParserProtocol

    var currentPolicy: AutofillPolicy?
    
    var preferences : Set<AutofillPolicy>
    
    var isActive: CurrentValueSubject<Bool, Never> = .init(true)

    private let autofillStorage: AutofillStorageProtocol
    let pageInformationProvider: PageInformationProvider
    private var cancellables = Set<AnyCancellable>()
    private let adminDisabledWebsites: [String]
    private var updatingActiveValueFromPreferences: Bool = false
    
    init(activeValue: AutofillPolicy.Policy = .everything,
         activeLevel: AutofillPolicy.Level = .domain,
         domainParser: DomainParserProtocol,
         pageInformationProvider: PageInformationProvider = SafariPageInformationProvider(),
         userEncryptedSettings: UserEncryptedSettings,
         popoverOpeningService: PopoverOpeningService,
         autofillStorage: AutofillStorageProtocol,
         adminDisabledWebsites: [String]) {
        self.userEncryptedSettings = userEncryptedSettings
        self.preferences = userEncryptedSettings.getAutofillPreferences()
        self.domainParser = domainParser
        self.activeLevel = activeLevel
        self.activeValue = activeValue
        self.pageInformationProvider = pageInformationProvider
        self.autofillStorage = autofillStorage
        self.adminDisabledWebsites = adminDisabledWebsites
        self.getCurrentURL()
        
        popoverOpeningService.publisher.sink { [weak self] opening in
            guard let self = self else { return }
            self.getCurrentURL()
        }.store(in: &cancellables)
    }

    private func changePolicyWithConfirmation(value: AutofillPolicy.Policy, for level: AutofillPolicy.Level, previousValue: AutofillPolicy.Policy) {

        guard value != currentPolicy?.policy else {
            return
        }

        if value == .disabled && !updatingActiveValueFromPreferences {
                        showDisableWebsiteConfirmationAlert = true
            previousActiveValue = previousValue
            return
        }

        disablePageChoicesIfNeeded()
        changePolicy(value: value, for: activeLevel)
    }

    func revertActiveValue() {
        guard let previous = previousActiveValue else { return }
        showDisableWebsiteConfirmationAlert = false
        activeValue = previous
        previousActiveValue = nil
    }

    func disableAutofill() {
        changePolicy(value: .disabled, for: activeLevel)
    }

    func changePolicy(value: AutofillPolicy.Policy, for level: AutofillPolicy.Level) {

        if let current = currentPolicy {
            current.policy = value
        } else {
            let policy = AutofillPolicy(policy: value, level: level, domain: domainTitle, pageURL: pageTitle)
            currentPolicy = policy
            preferences.insert(policy)
        }
        if level == .domain {
            correctPageValues(value)
        }
        self.saveSecuredData()
    }

            func correctPageValues(_ value: AutofillPolicy.Policy) {
        let pagePolicies = preferences.pagePolicies(forDomain: domainTitle)
            .filter({ !$0.policy.isStricterThan(other: value) })
        
        guard !pagePolicies.isEmpty else { return }
        preferences.subtract(preferences.pagePolicies(forDomain: domainTitle))
        saveSecuredData()
    }
    

        func resetPolicies() {
        let policies = preferences.policies(forDomain: domainTitle)
        preferences.subtract(policies)
        self.currentPolicy = nil
        self.saveSecuredData()
        self.updateActiveValue()
        self.disablePageChoicesIfNeeded()
    }

    func disablePageChoicesIfNeeded() {
        if self.activeLevel == .page && preferences.policy(forDomain: domainTitle)?.policy == .disabled {
            pageDisabled = true
        }
        else {
            pageDisabled = false
        }
    }

    func updateActiveValue() {
        let policyValue: AutofillPolicy.Policy
        if activeLevel == .page && currentPolicy?.policy == nil,
           let domainPreferences = self.preferences.policy(forDomain: domainTitle) {
                        policyValue = domainPreferences.policy
        } else {
            policyValue = currentPolicy?.policy ?? .everything
        }
        if policyValue != activeValue {
            activeValue = policyValue
        }
    }
    
    func saveSecuredData() {
        let filtered = preferences.filter { !$0.isDefault }
        let jsonData = try? JSONEncoder().encode(filtered)
        userEncryptedSettings[.autofillData] = jsonData
    }

    func findPreferences() {
        self.currentPolicy = self.preferences.first {
            switch activeLevel {
            case .page:
                return $0.subject == self.pageTitle
            case .domain:
                return $0.subject == self.domainTitle
            }
        }
        updatingActiveValueFromPreferences = true
        updateActiveValue()
        updatingActiveValueFromPreferences = false
    }
    
    public func getCurrentURL() {
        pageInformationProvider.currentPageURL { currentURL in
            guard let currentURL = currentURL else {
                self.isActive.value = false
                return
            }
            self.isActive.value = self.pageTitle.hasPrefix("_") || self.pageTitle.hasPrefix("_")
            let value = currentURL.absoluteString
            self.pageTitle = value
            let valueDomain = self.domainParser.parse(urlString: currentURL.absoluteString)?.name ?? ""
            self.domainTitle = valueDomain
            self.findPreferences()
            self.disableViewForDomainIfNeeded()
            self.disabledFields = self.autofillStorage.getUserDefinedRules().fieldsDisabled(forWebsite: valueDomain)
        }
    }

    private func disableViewForDomainIfNeeded() {
        if self.adminDisabledWebsites.contains(domainTitle) {
            self.viewDisabled = true
            changePolicy(value: .disabled, for: .domain)
        } else {
            self.viewDisabled = false
        }
    }

    func revertDisabledFields() {
        autofillStorage.removeUserDefinedRules(disabledFields)
        disabledFields.removeAll()
    }

    func learnMoreShushDashlane() {
        let url = URL(string: "_")!
        NSWorkspace.shared.openInSafari(url)
    }
}

private extension Sequence where Element == UserDefinedRule {
    func fieldsDisabled(forWebsite website: String) -> Set<UserDefinedRule> {
        Set(filter({ ($0.domain == website || website.hasSuffix($0.domain)) && $0.isDisabled }))
    }
}

extension UserEncryptedSettings {

    func getAutofillPreferences() -> Set<AutofillPolicy> {
        let preferencesData: Data? = self[.autofillData]
        let preferencesDecoded: Set<AutofillPolicy>? = try? JSONDecoder().decode(Set<AutofillPolicy>.self, from: preferencesData ?? Data())
        return preferencesDecoded ?? Set<AutofillPolicy>()
    }

}

extension Set where Element == AutofillPolicy {
    
    func policy(forPage page: String) -> Element? {
        self.first(where: {
            $0.subject == page && $0.level == .page
        })
    }
    
    func policy(forDomain domain: String) -> Element? {
        self.first(where: {
            $0.subject == domain && $0.level == .domain
        })
    }
    
    func pagePolicies(forDomain domain: String) -> Set<Element> {
        self.filter {
            $0.level == .page && $0.isMatching(url: domain)
        }
    }
    
    func policies(forDomain domain: String) -> Set<Element> {
        self.filter {
            $0.isMatching(url: domain)
        }
    }
}

extension AutofillViewModel {

    static func mock(url: URL = URL(string: "_")!,
                     rules: Set<UserDefinedRule> = []) -> AutofillViewModel {
        let container = MockServicesContainer()
        return AutofillViewModel(domainParser: container.domainParser,
                                 userEncryptedSettings: UserEncryptedSettings(internalStore: InMemoryLocalSettingsStore()),
                                 popoverOpeningService: PopoverOpeningService(),
                                 autofillStorage: AutofillStorageMock(rules: rules),
                                 adminDisabledWebsites: [])
    }
}
