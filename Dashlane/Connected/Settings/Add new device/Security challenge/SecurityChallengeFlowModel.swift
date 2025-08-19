import CoreSession
import CoreTypes
import Foundation
import LoginKit

@MainActor
class SecurityChallengeFlowModel: ObservableObject, SessionServicesInjecting {
  enum Step {
    case pendingtransfer
    case passphrase(SecurityChallengeKeys)
  }

  enum CompletionType {
    case completed(SecurityChallengeKeys)
    case intro
    case cancel
    case error(AddNewDeviceViewModel.Error)
  }

  @Published
  var steps: [Step]

  let login: String
  let transfer: PendingTransfer
  let senderSecurityChallengeService: SenderSecurityChallengeService
  let deviceTransferPendingRequestViewModelFactory: DeviceTransferPendingRequestViewModel.Factory
  let completion: (CompletionType) -> Void

  init(
    login: String, transfer: PendingTransfer,
    senderSecurityChallengeService: SenderSecurityChallengeService,
    deviceTransferPendingRequestViewModelFactory: DeviceTransferPendingRequestViewModel.Factory,
    completion: @escaping (SecurityChallengeFlowModel.CompletionType) -> Void
  ) {
    self.steps = [.pendingtransfer]
    self.login = login
    self.transfer = transfer
    self.senderSecurityChallengeService = senderSecurityChallengeService
    self.deviceTransferPendingRequestViewModelFactory = deviceTransferPendingRequestViewModelFactory
    self.completion = completion
  }

  func makeDeviceTransferPendingRequestViewModel() -> DeviceTransferPendingRequestViewModel {
    deviceTransferPendingRequestViewModelFactory.make(
      login: login, pendingTransfer: transfer,
      senderSecurityChallengeService: senderSecurityChallengeService
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .completed(transferKeys):
        self.steps.append(.passphrase(transferKeys))
      case let .failed(error):
        completion(.error(error))
      }
    }
  }

  func makePassphraseInputViewModel(transferKeys: SecurityChallengeKeys) -> PassphraseInputViewModel
  {
    PassphraseInputViewModel(
      passphrase: transferKeys.passphrase, deviceName: transfer.receiver.deviceName
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case .completed:
        self.completion(.completed(transferKeys))
      case .intro:
        self.completion(.intro)
      case .cancel:
        self.completion(.cancel)
      }
    }
  }
}

extension SecurityChallengeFlowModel {
  static var mock: SecurityChallengeFlowModel {
    SecurityChallengeFlowModel(
      login: "_", transfer: .mock, senderSecurityChallengeService: .mock,
      deviceTransferPendingRequestViewModelFactory: .init({ _, _, _, _ in
        .mock
      }), completion: { _ in })
  }
}
