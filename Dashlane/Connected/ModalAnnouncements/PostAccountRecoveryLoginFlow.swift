import Foundation
import SwiftUI
import UIDelight

struct PostAccountRecoveryLoginFlow: View {

    @Environment(\.dismiss)
    var dismiss

    @StateObject
    var model: PostAccountRecoveryLoginFlowModel

    var body: some View {
        StepBasedNavigationView(steps: $model.steps) { step in
            switch step {
                        case .changeMP, .recoveryKeyDisabled:
                PostAccountRecoveryLoginDisabledView(authenticationMethod: model.authenticationMethod) { result in
                    switch result {
                    case .goToSettings:
                        model.deeplinkService.handle(.goToSettings(.recoveryKey))
                        fallthrough
                    case .cancel:
                        dismiss()
                    }
                }
            }
        }
    }
}
