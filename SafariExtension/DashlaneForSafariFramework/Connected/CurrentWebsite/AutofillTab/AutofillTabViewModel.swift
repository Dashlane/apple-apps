import Foundation
import DomainParser
import Combine
import DashlaneAppKit
import DashTypes

class AutofillTabViewModel: TabActivable, SessionServicesInjecting {

    var currentWebsite: AutofillViewModel
    
    var isActive: CurrentValueSubject<Bool, Never> { currentWebsite.isActive }

    init(domainParser: DomainParser,
         userEncryptedSettings: UserEncryptedSettings,
         popoverOpeningService: PopoverOpeningService,
         autofillService: AutofillService,
         premiumService: PremiumService) {
        self.currentWebsite = AutofillViewModel(domainParser: domainParser,
                                                userEncryptedSettings: userEncryptedSettings,
                                                popoverOpeningService: popoverOpeningService,
                                                autofillStorage: autofillService.analysisLocalStorage,
                                                adminDisabledWebsites: premiumService.status?.disabledWebsites() ?? [])
    }
}
