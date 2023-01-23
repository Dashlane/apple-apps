import CorePersonalData
import DashlaneAppKit
import DashTypes
import CoreFeature
import Foundation
import SwiftUI
import VaultKit

class SecureNotesDetailFieldsModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let canEdit: Bool

    let service: DetailService<SecureNote>

    init(
        service: DetailService<SecureNote>,
        featureService: FeatureServiceProtocol
    ) {
        self.service = service
        self.canEdit = !featureService.isEnabled(.disableSecureNotes)
    }
}

extension SecureNotesDetailFieldsModel {
    static func mock(service: DetailService<SecureNote>) -> SecureNotesDetailFieldsModel {
        SecureNotesDetailFieldsModel(
            service: service,
            featureService: .mock()
        )
    }
}
