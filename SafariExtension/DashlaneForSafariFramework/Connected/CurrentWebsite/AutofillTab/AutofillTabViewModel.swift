import Foundation
import DomainParser
import Combine
import DashlaneAppKit
import DashTypes
import CoreFeature

class AutofillTabViewModel: TabActivable, SessionServicesInjecting {

    var currentWebsite: AutofillViewModel
    
    var isActive: CurrentValueSubject<Bool, Never> { currentWebsite.isActive }

    let isSafariDisabled: Bool

    init(domainParser: DomainParser,
         userEncryptedSettings: UserEncryptedSettings,
         popoverOpeningService: PopoverOpeningService,
         autofillService: AutofillService,
         premiumService: PremiumService,
         featureService: FeatureServiceProtocol) {
        self.isSafariDisabled = featureService.isEnabled(.autofillSafariIsDisabled)
        self.currentWebsite = AutofillViewModel(domainParser: domainParser,
                                                userEncryptedSettings: userEncryptedSettings,
                                                popoverOpeningService: popoverOpeningService,
                                                autofillStorage: autofillService.analysisLocalStorage,
                                                adminDisabledWebsites: premiumService.status?.disabledWebsites() ?? [])
    }
}
