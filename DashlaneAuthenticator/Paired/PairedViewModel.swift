import AuthenticatorKit
import Combine
import CoreSession
import CoreUserTracking
import Foundation

@MainActor
class PairedViewModel: ObservableObject {
  let services: PairedServicesContainer

  @Published
  var isLoading = true

  @Published
  var codes: Set<OTPInfo> = []

  @Published
  var lastCodeAdded: OTPInfo?

  @Published
  var lock: Lock?

  @Published
  var displayedSheet: ViewSheet?

  enum ViewSheet: Identifiable {
    case addItem(_ skipIntro: Bool = false)
    case addItemViaCameraApp(OTPInfo)

    var id: String {
      switch self {
      case .addItem:
        return "addItem"
      case .addItemViaCameraApp:
        return "addItemViaCameraApp"
      }
    }
  }

  var requestRating: Bool {
    return services.appServices.ratingService.requestRating
  }

  private var cancellables = Set<AnyCancellable>()

  init(services: PairedServicesContainer) {
    self.services = services
    services.databaseService.codesPublisher
      .assign(to: &$codes)
    services.databaseService.isLoadedPublisher
      .removeDuplicates()
      .map({ !$0 })
      .assign(to: &$isLoading)
  }

  func makeTokenListViewModel() -> TokenListViewModel {
    return services.makeTokenListViewModel { [weak self] otpInfo in
      self?.logDeletion(of: otpInfo)
    }
  }

  func makeAddItemRootViewModel() -> AddItemFlowViewModel {
    return services.makeAddItemFlowViewModel(
      hasAtLeastOneTokenStoredInVault: !codes.isEmpty,
      mode: .paired(services.sessionCredentialsProvider),
      completion: { self.lastCodeAdded = $0 })
  }

  func makeAddItemScanCodeFlowViewModel(otpInfo: OTPInfo, isFirstToken: Bool)
    -> AddItemScanCodeFlowViewModel
  {
    services.makeAddItemScanCodeFlowViewModel(
      otpInfo: otpInfo, mode: .paired(services.sessionCredentialsProvider),
      isFirstToken: isFirstToken
    ) { [weak self] (item, _) in
      self?.lastCodeAdded = item
      self?.displayedSheet = nil
    }
  }

  func makeUnlockViewModel() -> UnlockViewModel {

    return services.makeUnlockViewModel(
      login: services.session.login,
      authenticationMode: services.authenticationMode,
      loginOTPOption: services.session.configuration.info.loginOTPOption,
      validateMasterKey: { masterKey, _, _, _ in

        var serverKey: String?
        if self.services.session.configuration.info.loginOTPOption != .none {
          serverKey = self.services.appServices.keychainService.serverKey(
            for: self.services.session.login)
        }

        if masterKey.coreSessionMasterKey(withServerKey: serverKey)
          == self.services.session.authenticationMethod.sessionKey
        {
          return self.services
        } else {
          throw AccountError.unknown
        }
      },
      completion: { _ in
        self.lock = nil
      })
  }

  func logDeletion(of otpInfo: OTPInfo) {
    services.appServices.activityReporter.report(UserEvent.AuthenticatorRemoveOtpCode())
    services.appServices.activityReporter.report(
      AnonymousEvent.AuthenticatorRemoveOtpCode(
        authenticatorIssuerId: otpInfo.authenticatorIssuerId))
  }

  func didFinishRating() {
    services.appServices.ratingService.update()
  }
}
