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
                MasterPasswordView(model: model, showProgressIndicator: false)
            case let .biometry(model):
                BiometryView(model: model, showProgressIndicator: false)
            case let .pinCode(model):
                LockPinCodeAndBiometryView(model: model)
            }
        }
        .animation(.default, value: viewModel.lock)
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
                                          settings: InMemoryLocalSettingsStore(),
                                          keychainService: keychainService)
    }

    static var userSecuritySettings: UserSettings {
        return UserSettings(internalStore: InMemoryLocalSettingsStore())
    }

    static var previews: some View {
        let locker = ScreenLocker(masterKey: .masterPassword("Azerty12", serverKey: nil),
                                  secureLockProvider: SecureLockMode.masterKey,
                                  settings: InMemoryLocalSettingsStore(),
                                  teamSpaceService: .mock(),
                                  logger: LocalLogger(),
                                  login: login)
        let model = LockViewModel(locker: locker,
                                  keychainService: keychainService,
                                  userSettings: userSecuritySettings,
                                  resetMasterPasswordService: resetMasterPasswordService,
                                  installerLogService: InstallerLogService.mock,
                                  usageLogService: UsageLogService.fakeService,
                                  activityReporter: .fake,
                                  teamspaceService: .mock(),
                                  loginUsageLogService: LoginUsageLogService.mock,
                                  lockService: LockServiceMock(),
                                  sessionLifeCycleHandler: nil,
                                  changeMasterPasswordLauncher: {})

        LockView(viewModel: model)
    }
}

extension LockView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent()
    }

}
