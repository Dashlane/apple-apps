import CoreLocalization
import Foundation
import SwiftUI
import UIComponents
import UIDelight

struct DeviceTransferSecurityChallengeFlow: View {

  @StateObject
  var model: DeviceTransferSecurityChallengeFlowModel

  init(model: @autoclosure @escaping () -> DeviceTransferSecurityChallengeFlowModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case .intro:
        DeviceTransferSecurityChallengeIntroView(model: model.makeSecurityChallengeIntroViewModel())
      case let .passphrase(state, keys):
        DeviceTransferPassphraseView(
          model: model.makePassphraseViewModel(state: state, securityChallengeKeys: keys))
      }
    }
  }
}

struct DeviceTransferSecurityChallengeFlow_Preview: PreviewProvider {
  static var previews: some View {
    DeviceTransferSecurityChallengeFlow(
      model: .init(
        login: "_",
        securityChallengeIntroViewModelFactory: .init({ login, completion in
          DeviceTransferSecurityChallengeIntroViewModel(
            login: login, apiClient: .mock({}),
            securityChallengeTransferStateMachineFactory: .init({ _, _ in
              .mock
            }), completion: completion)
        }),
        passphraseViewModelFactory: .init({ state, words, transferId, secretBox, completion in
          DeviceTransferPassphraseViewModel(
            initialState: state, words: words, transferId: transferId, secretBox: secretBox,
            passphraseStateMachineFactory: .init({ _, _, _ in
              .mock
            }), completion: completion)
        }),
        securityChallengeFlowStateMachineFactory: .init({ _ in
          .mock
        }), completion: { _ in }))
  }
}
