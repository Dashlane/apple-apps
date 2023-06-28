import Foundation
import Combine
import CorePersonalData
import AuthenticationServices
import DashlaneAppKit
import AutofillKit
import VaultKit

extension AutofillService {
    convenience init(vaultItemsService: VaultItemsServiceProtocol) {
        self.init(channel: .fromApp, credentialsPublisher: vaultItemsService.$credentials.eraseToAnyPublisher())
    }
}
