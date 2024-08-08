import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit

@MainActor
class DeviceTransferPendingRequestViewModel: ObservableObject, SessionServicesInjecting {

  enum CompletionType {
    case completed(SecurityChallengeKeys)
    case failed(AddNewDeviceViewModel.Error)
  }

  let login: String
  let pendingTransfer: PendingTransfer
  let senderSecurityChallengeService: SenderSecurityChallengeService
  let formatter: DateFormatter
  let completion: (CompletionType) -> Void

  @Published
  var isLoading = false

  @Published
  var progressState: ProgressionState = .inProgress(
    L10n.Localizable.Mpless.D2d.Universal.Trusted.loadingChallenge)

  var displayLocation: String {
    "\(pendingTransfer.receiver.city)" + ", "
      + "\(Locale.current.localizedString(forRegionCode: pendingTransfer.receiver.countryCode) ?? "")"
  }

  init(
    login: String, pendingTransfer: PendingTransfer,
    senderSecurityChallengeService: SenderSecurityChallengeService,
    completion: @escaping (DeviceTransferPendingRequestViewModel.CompletionType) -> Void
  ) {
    self.login = login
    self.pendingTransfer = pendingTransfer
    self.senderSecurityChallengeService = senderSecurityChallengeService
    self.formatter = DateFormatter()
    formatter.dateFormat = "MMM d, h:mm a"
    formatter.calendar = .current
    self.completion = completion
  }

  func displayDate() -> String {
    let date = Date(
      timeIntervalSince1970: TimeInterval(pendingTransfer.receiver.requestedAtDateUnix))
    return formatter.string(from: date)
  }

  func confirmRequest() async {
    do {
      isLoading = true
      let keys = try await senderSecurityChallengeService.transferKeys(for: pendingTransfer)
      completion(.completed(keys))
    } catch let error as URLError where error.code == .timedOut {
      completion(.failed(.timeout))
    } catch {
      completion(.failed(.generic))
    }
  }
}

extension DeviceTransferPendingRequestViewModel {
  static var mock: DeviceTransferPendingRequestViewModel {
    return DeviceTransferPendingRequestViewModel(
      login: "_", pendingTransfer: .mock, senderSecurityChallengeService: .mock
    ) { _ in }
  }
}

extension PendingTransfer {
  static var mock: PendingTransfer {
    PendingTransfer(
      transferId: "transferId",
      receiver: .init(
        hashedPublicKey: "hashedPublicKey",
        deviceName: "Dashlane's iPhone 15 Pro",
        devicePlatform: nil,
        countryCode: "FR",
        city: "Paris",
        requestedAtDateUnix: Int(Date().timeIntervalSince1970)))
  }
}
