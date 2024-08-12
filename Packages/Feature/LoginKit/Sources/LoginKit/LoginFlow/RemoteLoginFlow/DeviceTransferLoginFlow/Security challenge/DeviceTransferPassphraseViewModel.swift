import CoreCrypto
import CoreLocalization
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftUI

@MainActor
public class DeviceTransferPassphraseViewModel: ObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(AccountTransferInfo)
    case cancel
    case failure(TransferError)
  }

  let words: [String]
  let transferId: String
  let completion: (CompletionType) -> Void

  @Published
  var isLoading: Bool = false

  @Published
  var progressState: ProgressionState = .inProgress(
    L10n.Core.Mpless.D2d.Universal.Untrusted.loadingAccount)

  public var stateMachine: PassphraseVerificationStateMachine

  public init(
    initialState: PassphraseVerificationStateMachine.State,
    words: [String],
    transferId: String,
    secretBox: DeviceTransferSecretBox,
    passphraseStateMachineFactory: PassphraseVerificationStateMachine.Factory,
    completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
  ) {
    self.words = words
    self.transferId = transferId
    self.stateMachine = passphraseStateMachineFactory.make(
      initialState: initialState, transferId: transferId, secretBox: secretBox)
    self.completion = completion
    Task {
      try await perform(.requestTransferData)
    }
  }

  func cancel() {
    completion(.cancel)
  }
}

@MainActor
extension DeviceTransferPassphraseViewModel: StateMachineBasedObservableObject {
  public func update(
    for event: PassphraseVerificationStateMachine.Event,
    from oldState: PassphraseVerificationStateMachine.State,
    to newState: PassphraseVerificationStateMachine.State
  ) {
    switch newState {
    case .initializing:
      isLoading = true
    case let .transferCompleted(data):
      self.completion(.completed(data))
    case let .transferError(error):
      self.completion(.failure(error))
    case .cancelled:
      self.completion(.cancel)
    }
  }
}

extension DeviceTransferPassphraseViewModel {
  static var mock: DeviceTransferPassphraseViewModel {
    DeviceTransferPassphraseViewModel(
      initialState: .initializing,
      words: ["One", "Two", "Three", "Four", "Five"],
      transferId: "transferId",
      secretBox: DeviceTransferSecretBoxMock.mock(),
      passphraseStateMachineFactory: .init({ _, _, _ in
        .mock
      }),
      completion: { _ in })
  }
}
