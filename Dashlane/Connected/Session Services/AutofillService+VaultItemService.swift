import Foundation
import Combine
import CorePersonalData
import AuthenticationServices
import DashlaneAppKit

extension AutofillService {
    convenience init(vaultItemsService: VaultItemsServiceProtocol) {
        self.init(channel: .fromApp, credentialsPublisher: vaultItemsService.$credentials.eraseToAnyPublisher())
    }
}
