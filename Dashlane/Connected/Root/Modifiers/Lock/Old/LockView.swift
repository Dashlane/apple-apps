import Combine
import CoreKeychain
import CorePersonalData
import CoreSession
import CoreSettings
import DashTypes
import Logger
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct LockView: View {
  @StateObject
  var viewModel: LockViewModel

  public init(viewModel: @autoclosure @escaping () -> LockViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    ZStack {
      switch self.viewModel.mode {
      case .privacyShutter:
        VStack {
          LoginLogo()
            .fixedSize()
          Spacer()
        }
        .padding(.top, 20)
        .loginAppearance()
      case let .masterPassword(model):
        MasterPasswordLocalView(model: model, showProgressIndicator: false)
      case let .biometry(model):
        BiometryView(model: model, showProgressIndicator: false)
      case let .pinCode(model):
        LockPinCodeAndBiometryView(model: model)
      case .sso:
        SSOUnlockView(model: viewModel.makeSSOUnlockViewModel())
      case let .passwordLessRecovery(recoverFromFailure):
        PasswordLessRecoveryView(
          model: viewModel.makePasswordLessRecoveryViewModel(recoverFromFailure: recoverFromFailure)
        )
      }
    }
    .animation(.default, value: viewModel.lock)
    .fullScreenCover(item: $viewModel.newMasterPassword) { newMasterPassword in
      PostARKChangeMasterPasswordView(
        model: viewModel.makePostARKChangeMasterPasswordViewModel(
          newMasterPassword: newMasterPassword))
    }
  }
}

struct LockView_Previews: PreviewProvider {
  static let login = Login("_")
  static var keychainService: AuthenticationKeychainServiceProtocol = .mock

  static var resetMasterPasswordService: ResetMasterPasswordService {
    return ResetMasterPasswordService(
      login: login,
      settings: .mock(),
      keychainService: keychainService)
  }

  static var userSecuritySettings: UserSettings {
    return UserSettings(internalStore: .mock())
  }

  static var previews: some View {
    let locker = ScreenLocker(
      masterKey: .masterPassword("_", serverKey: nil),
      secureLockProvider: SecureLockMode.masterKey,
      settings: .mock(),
      userSpacesService: .mock(),
      logger: LocalLogger(),
      session: .mock)
    let model = LockViewModel(
      locker: locker,
      session: .mock,
      appServices: (try? AppServicesContainer(
        sessionLifeCycleHandler: FakeSessionLifeCycleHandler(),
        crashReporter: CrashReporterService(target: .app), appLaunchTimeStamp: 1))!,
      appAPIClient: .fake,
      userDeviceAPIClient: .fake,
      nitroClient: .fake,
      keychainService: .mock,
      userSettings: userSecuritySettings,
      resetMasterPasswordService: resetMasterPasswordService,
      activityReporter: .mock,
      userSpacesService: .mock(),
      loginMetricsReporter: .fake,
      lockService: LockServiceMock(),
      sessionLifeCycleHandler: nil,
      syncService: .mock(),
      sessionCryptoUpdater: .mock,
      syncedSettings: .mock,
      databaseDriver: InMemoryDatabaseDriver(),
      logger: LoggerMock(),
      newMasterPassword: "_",
      changeMasterPasswordLauncher: {},
      postARKChangeMasterPasswordViewModelFactory: .init({ _, _ in
        .mock
      }))

    LockView(viewModel: model)
  }
}

extension LockView: NavigationBarStyleProvider {
  var navigationBarStyle: UIComponents.NavigationBarStyle {
    return .transparent()
  }

}
