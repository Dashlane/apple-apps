import Combine
import CoreCrypto
import CoreSession
import CoreTypes
import DashlaneAPI
import DesignSystem
import Foundation
import LogFoundation
import LoginKit
import UserTrackingFoundation

@MainActor
class AddNewDeviceViewModel: ObservableObject, SessionServicesInjecting {

  enum State: Equatable {
    case loading
    case pendingTransfer(PendingTransfer)
    case intro
    case error(AddNewDeviceViewModel.Error)
  }

  @Published
  var progressState: ProgressionState = .inProgress(L10n.Localizable.addNewDeviceInProgress)

  @Published
  var showScanner = false

  @Published
  var state: State = .intro

  private let apiClient: UserDeviceAPIClient
  private let activityReporter: ActivityReporterProtocol
  private let session: Session
  private let senderQRCodeService: SenderQRCodeService
  private let senderSecurityChallengeService: SenderSecurityChallengeService
  private let securityChallengeFlowModelFactory: SecurityChallengeFlowModel.Factory

  var dismissPublisher = PassthroughSubject<Void, Never>()

  init(
    session: Session,
    apiClient: UserDeviceAPIClient,
    activityReporter: ActivityReporterProtocol,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider,
    securityChallengeFlowModelFactory: SecurityChallengeFlowModel.Factory,
    qrCodeViaSystemCamera: String? = nil
  ) {
    self.session = session
    self.apiClient = apiClient
    self.activityReporter = activityReporter
    self.senderQRCodeService = SenderQRCodeService(
      session: session, apiClient: apiClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider, ecdh: ECDH())
    self.securityChallengeFlowModelFactory = securityChallengeFlowModelFactory
    do {
      self.senderSecurityChallengeService = SenderSecurityChallengeService(
        session: session, apiClient: apiClient,
        cryptoProvider: try DeviceTransferCryptoKeysProviderImpl())
    } catch {
      fatalError()
    }
    if let qrcode = qrCodeViaSystemCamera {
      didScanQRCode(qrcode)
    } else {
      checkPendingRequest()
    }
  }

  func checkPendingRequest() {
    guard isPasswordlessAccount else {
      return
    }
    state = .loading
    Task {
      if let pendingRequest = try? await senderSecurityChallengeService.pendingTransfer() {
        state = .pendingTransfer(pendingRequest)
      } else {
        state = .intro
      }
    }
  }

  func didScanQRCode(_ qrcode: String) {
    state = .loading
    Task {
      await startTransfer(withQRCode: qrcode)
    }
  }

  private func startTransfer(withQRCode qrcode: String) async {
    do {
      try await senderQRCodeService.startTransfer(withQRCode: qrcode)
      self.progressState = .completed(
        L10n.Localizable.addNewDeviceCompleted,
        {
          self.dismissPublisher.send()
        })
      self.activityReporter.reportPageShown(Page.settingsAddNewDeviceSuccess)
    } catch {
      state = .error(.generic)
    }
  }

  func startUniversalTransfer(with transferKeys: SecurityChallengeKeys) async {
    do {
      state = .loading
      try await senderSecurityChallengeService.startUniversalTransfer(
        with: transferKeys,
        secretBox: DeviceTransferSecretBoxImpl(
          cryptoEngine: DeviceTransferCryptoEngine(symmetricKey: transferKeys.symmetricKey)))
      self.progressState = .completed(
        L10n.Localizable.Mpless.D2d.Universal.Trusted.completedChallenge,
        {
          self.dismissPublisher.send()
        })
      self.activityReporter.reportPageShown(Page.settingsAddNewDeviceSuccess)
    } catch let error as DashlaneAPI.APIError
      where error.hasSecretTransferCode(APIErrorCodes.SecretTransfer.transferDoesNotExists)
    {
      state = .error(.timeout)
    } catch {
      state = .error(.generic)
    }
  }

  func makeSecurityChallengeFlowModel(for transfer: PendingTransfer) -> SecurityChallengeFlowModel {
    securityChallengeFlowModelFactory.make(
      login: session.login.email, transfer: transfer,
      senderSecurityChallengeService: senderSecurityChallengeService
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .completed(transferKeys):
        Task {
          await self.startUniversalTransfer(with: transferKeys)
        }
      case .intro:
        state = .intro
      case .cancel:
        dismissPublisher.send()
      case let .error(error):
        state = .error(error)
      }

    }
  }
}

extension AddNewDeviceViewModel {
  static func mock(accountType: CoreSession.AccountType) -> AddNewDeviceViewModel {
    AddNewDeviceViewModel(
      session: .mock(accountType: accountType), apiClient: .fake, activityReporter: .mock,
      sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: .mock),
      securityChallengeFlowModelFactory: .init({ _, _, _, _ in
        .mock
      }), qrCodeViaSystemCamera: nil)
  }
}

extension AddNewDeviceViewModel {
  var isPasswordlessAccount: Bool {
    session.configuration.info.accountType == .invisibleMasterPassword
  }

  var title: String {
    return isPasswordlessAccount
      ? L10n.Localizable.Mpless.D2d.trustedIntroTitle : L10n.Localizable.addNewDeviceTitle
  }

  var message1: String {
    return isPasswordlessAccount
      ? L10n.Localizable.Mpless.D2d.trustedIntroMessage1 : L10n.Localizable.addNewDeviceMessage1
  }

  var message2: String {
    return isPasswordlessAccount
      ? L10n.Localizable.Mpless.D2d.trustedIntroMessage2 : L10n.Localizable.addNewDeviceMessage2
  }

  var message3: String {
    return isPasswordlessAccount
      ? L10n.Localizable.Mpless.D2d.trustedIntroMessage3 : L10n.Localizable.addNewDeviceMessage3
  }
}

extension AddNewDeviceViewModel {
  @Loggable
  enum Error {
    case timeout
    case generic
  }
}
