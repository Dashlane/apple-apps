import Combine
import CorePersonalData
import CoreSettings
import CoreUserTracking
import DashlaneAppKit
import DashlaneReportKit
import DashTypes
import Foundation
import SwiftUI
import VaultKit

class CredentialMainSectionModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    @Binding
    var code: String

    @Binding
    var isAutoFillDemoModalShown: Bool

    @Binding
    var isAdd2FAFlowPresented: Bool

    var emailsSuggestions: [String] {
        vaultItemsService.emails.map(\.value).sorted()
    }

    let passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory

    let service: DetailService<Credential>

    private var sharingService: SharedVaultHandling {
        service.sharingService
    }
    private var vaultItemsService: VaultItemsServiceProtocol {
        service.vaultItemsService
    }

    init(
        service: DetailService<Credential>,
        code: Binding<String>,
        isAutoFillDemoModalShown: Binding<Bool>,
        isAdd2FAFlowPresented: Binding<Bool>,
        passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory
    ) {
        self.service = service
        self._code = code
        self._isAutoFillDemoModalShown = isAutoFillDemoModalShown
        self._isAdd2FAFlowPresented = isAdd2FAFlowPresented
        self.passwordAccessorySectionModelFactory = passwordAccessorySectionModelFactory
    }
}

extension CredentialMainSectionModel {
    static func mock(
        service: DetailService<Credential>,
        code: Binding<String>,
        isAutoFillDemoModalShown: Binding<Bool>,
        isAdd2FAFlowPresented: Binding<Bool>
    ) -> CredentialMainSectionModel {
        CredentialMainSectionModel(
            service: service,
            code: code,
            isAutoFillDemoModalShown: isAutoFillDemoModalShown,
            isAdd2FAFlowPresented: isAdd2FAFlowPresented,
            passwordAccessorySectionModelFactory: .init { .mock(service: $0) }
        )
    }
}
