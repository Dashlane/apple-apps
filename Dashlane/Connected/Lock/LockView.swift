import SwiftUI
import Combine
import CoreSession
import CoreKeychain
import Logger
import DashlaneAppKit
import DashTypes
import LoginKit
import CoreSettings
import UIDelight
import UIComponents
import CorePersonalData

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
            case let .sso(login):
                SSOUnlockView(login: login, completion: viewModel.unlockWithSSO)
            case let .passwordLessRecovery(recoverFromFailure):
                PasswordLessRecoveryView(model: viewModel.makePasswordLessRecoveryViewModel(recoverFromFailure: recoverFromFailure))
            }
        }
        .animation(.default, value: viewModel.lock)
        .fullScreenCover(item: $viewModel.newMasterPassword) { newMasterPassword in
            PostARKChangeMasterPasswordView(model: viewModel.makePostARKChangeMasterPasswordViewModel(newMasterPassword: newMasterPassword))
        }
    }
}

struct LockView_Previews: PreviewProvider {
    struct FakeCryptoEngine: KeychainCryptoEngine {
        func encrypt(data: Data, using password: String) -> Data? { return nil }
        func decrypt(data: Data, using password: String) -> Data? { return nil }
    }

    static let login = Login("_")
    static var keychainService: AuthenticationKeychainService {
        return AuthenticationKeychainService(cryptoEngine: FakeCryptoEngine(), keychainSettingsDataProvider: FakeSettingsFactory(), accessGroup: ApplicationGroup.keychainAccessGroup)
    }

    static var resetMasterPasswordService: ResetMasterPasswordService {
        return ResetMasterPasswordService(login: login,
                                          settings: .mock(),
                                          keychainService: keychainService)
    }

    static var userSecuritySettings: UserSettings {
        return UserSettings(internalStore: .mock())
    }

    static var previews: some View {
        let locker = ScreenLocker(masterKey: .masterPassword("Azerty12", serverKey: nil),
                                  secureLockProvider: SecureLockMode.masterKey,
                                  settings: .mock(),
                                  teamSpaceService: .mock(),
                                  logger: LocalLogger(),
                                  login: login)
        let model = LockViewModel(locker: locker,
                                  session: .mock,
                                  appServices: (try? AppServicesContainer(sessionLifeCycleHandler: FakeSessionLifeCycleHandler(), crashReporter: CrashReporterService(target: .app), appLaunchTimeStamp: 1))!,
                                  appAPIClient: .fake,
                                  userDeviceAPIClient: .fake,
                                  keychainService: keychainService,
                                  userSettings: userSecuritySettings,
                                  resetMasterPasswordService: resetMasterPasswordService,
                                  activityReporter: .fake,
                                  teamspaceService: .mock(),
                                  loginMetricsReporter: .fake,
                                  lockService: LockServiceMock(),
                                  sessionLifeCycleHandler: nil,
                                  syncService: SyncServiceMock(),
                                  sessionCryptoUpdater: .mock,
                                  syncedSettings: .mock,
                                  databaseDriver: InMemoryDatabaseDriver(),
                                  logger: LoggerMock(),
                                  newMasterPassword: "Azerty12",
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
