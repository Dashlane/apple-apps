import Foundation
import CorePersonalData
import DomainParser
import DashlaneAppKit
import CoreSettings
import DashTypes

class MiniBrowserViewModel: ObservableObject, SessionServicesInjecting {

    enum Completion {
        case back
        case done
        case generatedPasswordCopiedToClipboard(String)
    }

    @Published
    var cardCollapsed: Bool = false

    let passwordChangeUrl: URL?
    let url: URL
    let domain: String
    let cardViewModel: MiniBrowserCardViewModel
    let completion: (Completion) -> Void

    init(email: String, password: String,
         displayableDomain: String,
         url: URL,
         domainParser: DomainParserProtocol,
         usageLogService: DWMLogService,
         userSettings: UserSettings,
         completion: @escaping (MiniBrowserViewModel.Completion) -> Void) {
        self.url = url
        self.domain = url.host.flatMap(domainParser.parse)?.domain ?? ""
        self.completion = completion
        self.cardViewModel = MiniBrowserCardViewModel(email: email, password: password, domain: displayableDomain, usageLogService: usageLogService, userSettings: userSettings) { result in
            switch result {
            case .generatedPasswordCopiedToClipboard(let password):
                completion(.generatedPasswordCopiedToClipboard(password))
            }
        }

        if let directUrl = PasswordChangeURLs.urls[domain] {
            self.passwordChangeUrl = URL(string: directUrl)
        } else {
            self.passwordChangeUrl = nil
        }
    }

    private init(url: URL, domain: String, cardViewModel: MiniBrowserCardViewModel, completion: @escaping (MiniBrowserViewModel.Completion) -> Void) {
        self.url = url
        self.domain = domain
        self.completion = completion
        self.passwordChangeUrl = nil
        self.cardViewModel = cardViewModel
    }

    func back() {
        completion(.back)
    }

    func done() {
        completion(.done)
    }
}

extension MiniBrowserViewModel {
    private static var cardViewModel: MiniBrowserCardViewModel {
        MiniBrowserCardViewModel(email: "_", password: "123", domain: "test.com", usageLogService: DWMLogService.fakeService, userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore())) {_ in}
    }

    static func mock(url: URL, domain: String) -> MiniBrowserViewModel {
        return MiniBrowserViewModel(url: url, domain: domain, cardViewModel: cardViewModel, completion: {_ in})
    }
}
