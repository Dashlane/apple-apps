import CorePersonalData
import DashlaneAppKit
import CoreFeature
import Foundation
import SwiftUI
import VaultKit

class SecureNotesDetailNavigationBarModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var isEditingContent: FocusState<Bool>.Binding

    let canEdit: Bool

    let service: DetailService<SecureNote>

    init(
        service: DetailService<SecureNote>,
        isEditingContent: FocusState<Bool>.Binding,
        featureService: FeatureServiceProtocol
    ) {
        self.service = service
        self.isEditingContent = isEditingContent
        self.canEdit = !featureService.isEnabled(.disableSecureNotes)
    }
}

extension SecureNotesDetailNavigationBarModel {
    static func mock(
        service: DetailService<SecureNote>,
        isContentEditing: FocusState<Bool>.Binding
    ) -> SecureNotesDetailNavigationBarModel {
        SecureNotesDetailNavigationBarModel(
            service: service,
            isEditingContent: isContentEditing,
            featureService: .mock()
        )
    }
}
