import CoreCrypto
import CoreLocalization
import CoreSession
import CoreTypes
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
  let completion: (CompletionType) -> Void

  @Published
  var isLoading: Bool = false

  @Published
  var progressState: ProgressionState = .inProgress(
    CoreL10n.Mpless.D2d.Universal.Untrusted.loadingAccount)

  @Published public var stateMachine: PassphraseVerificationStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    stateMachine: PassphraseVerificationStateMachine,
    words: [String],
    completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
  ) {
    self.words = words
    self.stateMachine = stateMachine
    self.completion = completion
    Task {
      await perform(.requestTransferData)
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
      stateMachine: .mock,
      words: ["One", "Two", "Three", "Four", "Five"],
      completion: { _ in })
  }
}
