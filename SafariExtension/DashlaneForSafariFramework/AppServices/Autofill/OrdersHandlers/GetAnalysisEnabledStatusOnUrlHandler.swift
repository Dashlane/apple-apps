import Foundation
import DomainParser
import CorePremium
import CoreFeature
import DashlaneAppKit
import DashTypes

struct GetAnalysisEnabledStatusOnUrlHandler: MaverickOrderHandleable {

    struct Request: Decodable {
        let url: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let status: AnalysisStatus
    }
    
    enum SessionState {
        case loggedOut
        case loggedIn(AuthenticatedAnalysisStatusHandler)
    }
    
            enum AnalysisStatus: String, Encodable {
        case enabled = "ANALYSIS_ENABLED"
        case onlyOnLoginForms = "ANALYSIS_ENABLED_ONLY_ON_LOGIN_FORMS"
        case disabledByUser = "ANALYSIS_DISABLED_BY_USER"
        case disabledByTeam = "ANALYSIS_DISABLED_BY_B2B_ADMIN"
        case disabledByKillSwitch = "ANALYSIS_DISABLED_BY_KILLSWITCH"
    }

    let maverickOrderMessage: MaverickOrderMessage
    let sessionState: SessionState
    
    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        let status: AnalysisStatus
        switch sessionState {
        case .loggedOut:
            status = .enabled
        case let .loggedIn(handler):
            status = handler.status(forPageAtURL: request.url)
        }
        return Response(id: actionMessageID, status: status)
    }
}

struct AuthenticatedAnalysisStatusHandler: SessionServicesInjecting {
    
    let premiumService: PremiumService
    let userEncryptedSettings: UserEncryptedSettings
    let domainParser: DomainParser
    let killSwitchService: KillSwitchServiceProtocol
    
    init(premiumService: PremiumService, userEncryptedSettings: UserEncryptedSettings, domainParser: DomainParser, killSwitchService: KillSwitchServiceProtocol) {
        self.premiumService = premiumService
        self.userEncryptedSettings = userEncryptedSettings
        self.domainParser = domainParser
        self.killSwitchService = killSwitchService
    }
    
    func status(forPageAtURL url: String) -> GetAnalysisEnabledStatusOnUrlHandler.AnalysisStatus {
        let autofillData = userEncryptedSettings.getAutofillPreferences()
        let autofillPolicy = autofillData.policy(forPageAtURL: url, domainParser: domainParser)
        
                switch autofillPolicy?.policy {
        case .disabled:
            return .disabledByUser
        case .loginPasswordsOnly:
            return .onlyOnLoginForms
        default: break
        }
        
                let disabledWebsites = (premiumService.status?.spaces ?? [])
            .map { $0.info.autologinDomainDisabledArray }
            .compactMap { $0 }
            .flatMap { $0 }
        
        if let domain = domainParser.parse(urlString: url),
           disabledWebsites.contains(domain.name) {
            return .disabledByTeam
        }
        
                guard !killSwitchService.isDisabled(.disableAutofill) else {
            return .disabledByKillSwitch
        }
        
        return .enabled
    }
}
