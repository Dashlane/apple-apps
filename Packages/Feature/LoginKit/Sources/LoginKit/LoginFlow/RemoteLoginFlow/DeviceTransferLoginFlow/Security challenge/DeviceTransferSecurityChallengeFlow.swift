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
        login: "_", stateMachine: .mock,
        securityChallengeIntroViewModelFactory: .init({ login, stateMachine, completion in
          DeviceTransferSecurityChallengeIntroViewModel(
            login: login, stateMachine: stateMachine, apiClient: .mock({}), completion: completion)
        }),
        passphraseViewModelFactory: .init({ _, words, completion in
          DeviceTransferPassphraseViewModel(
            stateMachine: .mock, words: words, completion: completion)
        }), completion: { _ in }))
  }
}
