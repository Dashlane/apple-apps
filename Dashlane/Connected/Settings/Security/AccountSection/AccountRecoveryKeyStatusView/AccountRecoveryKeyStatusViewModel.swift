import Combine
import CoreSession
import DashlaneAPI
import Foundation

@MainActor
public class AccountRecoveryKeyStatusViewModel: ObservableObject, SessionServicesInjecting {

  enum Status: Hashable {
    case loading
    case error
    case noInternet
    case keySatus(Bool)

    var id: String {
      switch self {
      case .loading:
        return "loading"
      case .error:
        return "error"
      case let .keySatus(isEnabled):
        return isEnabled ? "statusOn" : "statusOff"
      case .noInternet:
        return "noInternet"
      }
    }
  }

  @Published
  var status: Status = .loading

  private let login: String
  private let appAPIClient: AppAPIClient
  private let userAPIClient: UserDeviceAPIClient
  private let recoveryKeyStatusDetailViewModelFactory:
    AccountRecoveryKeyStatusDetailViewModel.Factory
  private let reachability: NetworkReachability
  private var subcription: AnyCancellable?

  init(
    session: Session,
    appAPIClient: AppAPIClient,
    userAPIClient: UserDeviceAPIClient,
    reachability: NetworkReachability,
    recoveryKeyStatusDetailViewModelFactory: AccountRecoveryKeyStatusDetailViewModel.Factory
  ) {
    self.login = session.login.email
    self.appAPIClient = appAPIClient
    self.userAPIClient = userAPIClient
    self.recoveryKeyStatusDetailViewModelFactory = recoveryKeyStatusDetailViewModelFactory
    self.reachability = reachability
    Task {
      await fetchStatus()
    }
  }

  func fetchStatus() async {
    guard self.reachability.isConnected else {
      status = .noInternet
      fetchWhenInternetConnectionRestores()
      return
    }
    do {
      let response = try await appAPIClient.accountrecovery.getStatus(login: login)
      status = .keySatus(response.enabled)
    } catch {
      status = self.reachability.isConnected ? .error : .noInternet
      fetchWhenInternetConnectionRestores()
    }
  }

  private func fetchWhenInternetConnectionRestores() {
    guard !self.reachability.isConnected else {
      return
    }

    subcription = reachability.$isConnected
      .receive(on: DispatchQueue.main)
      .filter { $0 }.sink { [weak self] _ in
        Task {
          await self?.fetchStatus()
        }
      }
  }

  func makeAccountRecoveryKeyStatusDetailViewModel(isEnabled: Bool)
    -> AccountRecoveryKeyStatusDetailViewModel
  {
    recoveryKeyStatusDetailViewModelFactory.make(isEnabled: isEnabled)
  }
}

extension AccountRecoveryKeyStatusViewModel {
  static var mock: AccountRecoveryKeyStatusViewModel {
    AccountRecoveryKeyStatusViewModel(
      session: .mock, appAPIClient: .fake, userAPIClient: .fake,
      reachability: NetworkReachability(isConnected: true),
      recoveryKeyStatusDetailViewModelFactory: AccountRecoveryKeyStatusDetailViewModel.Factory({
        _ in
        AccountRecoveryKeyStatusDetailViewModel.mock
      }))
  }
}
