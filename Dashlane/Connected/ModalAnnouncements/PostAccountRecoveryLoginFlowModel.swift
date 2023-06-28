import Foundation
import CoreSession

class PostAccountRecoveryLoginFlowModel: SessionServicesInjecting, ObservableObject {
    let authenticationMethod: AuthenticationMethod

    enum Step: Identifiable {
        case changeMP(String)
        case recoveryKeyDisabled
        var id: String {
            switch self {
            case .changeMP:
                return "changeMP"
            case .recoveryKeyDisabled:
                return "recoveryKeyDisabled"
            }
        }
    }

    @Published
    var steps: [Step]

    let changeMasterPasswordFlowViewModelFactory: ChangeMasterPasswordFlowViewModel.Factory
    let deeplinkService: DeepLinkingService

    init(authenticationMethod: AuthenticationMethod,
         deeplinkService: DeepLinkingService,
         changeMasterPasswordFlowViewModelFactory: ChangeMasterPasswordFlowViewModel.Factory) {
        self.authenticationMethod = authenticationMethod
        self.deeplinkService = deeplinkService
        self.changeMasterPasswordFlowViewModelFactory = changeMasterPasswordFlowViewModelFactory
        if let password = authenticationMethod.userMasterPassword {
            steps = [.changeMP(password)]
        } else {
            steps = [.recoveryKeyDisabled]
        }
    }
}
