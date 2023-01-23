import Foundation
import CorePersonalData
import DashlaneAppKit
import VaultKit

extension VaultItemsService {
    func configurePrefilledCredentials(using urlDecoder: CorePersonalData.PersonalDataURLDecoder) {
        let prefilledCredentials = PrefilledCredentials.all()
        self.prefilledCredentials = prefilledCredentials.map { Credential(service: $0,
                                                                            email: login.email,
                                                                            url: try? urlDecoder.decodeURL($0.url),
                                                                            credentialCategories: credentialCategories) }

    }
}
