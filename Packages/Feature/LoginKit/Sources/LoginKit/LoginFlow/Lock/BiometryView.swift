#if canImport(UIKit)
import Foundation
import SwiftUI
import CoreSession
import SwiftTreats
import DashTypes
import UIDelight
import CoreLocalization
import DesignSystem
import UIComponents

public struct BiometryView<Model: BiometryViewModelProtocol>: View {
    @StateObject
    var model: Model
    let showProgressIndicator: Bool

    public init(model: @autoclosure @escaping () -> Model, showProgressIndicator: Bool = true) {
        self._model = .init(wrappedValue: model())
        self.showProgressIndicator = showProgressIndicator
    }

    public var body: some View {
        GravityAreaVStack(top: LoginLogo(login: self.model.login),
                          center: centerView)
            .loginAppearance()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(label: L10n.Core.kwBack,
                               color: .ds.text.neutral.catchy,
                               action: model.cancel)
                }
            }
            .onAppear {
                self.model.logAskAuthentication()
                if !self.model.manualLockOrigin {
                    Task {
                        await self.model.validate()
                    }
                }
        }
        .reportPageAppearance(.unlockBiometric)
            .animation(.default, value: showProgressIndicator)
        .loading(isLoading: model.shouldDisplayProgress && showProgressIndicator, loadingIndicatorOffset: true)
    }

    var centerView: some View {
        VStack {
            Text(L10n.Core.kwLockBiometryTypeLoadingMsg(model.biometryType.displayableName)).foregroundColor(.ds.text.neutral.catchy)

            Button(action: {
                Task {
                    await self.model.validate()
                }
            }) {
                Image(asset: model.biometryType == .touchId ? Asset.fingerprint : Asset.faceId)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
            .opacity(!model.shouldDisplayProgress ? 1 : 0.5)
            .disabled(model.shouldDisplayProgress)
        }
    }

    private var biometryImage: Image {
        if model.biometryType == .touchId {
            return Asset.fingerprint.swiftUIImage
        } else {
            return Asset.faceId.swiftUIImage
        }
    }
}

struct BiometryView_Previews: PreviewProvider {

    class FakeBiometryViewModel: BiometryViewModelProtocol {

        let login: Login
        let biometryType: Biometry
        @Published
        var shouldDisplayProgress: Bool

        var canShowPrompt: Bool = true
        var manualLockOrigin: Bool = false

        init(login: Login, biometryType: Biometry, shouldDisplayProgress: Bool = false) {
            self.login = login
            self.biometryType = biometryType
            self.shouldDisplayProgress = shouldDisplayProgress
        }

        func validate() {}
        func cancel() {}
        func logAskAuthentication() {}
    }

    static var previews: some View {
        Group {
            BiometryView(model: FakeBiometryViewModel(login: Login("_"), biometryType: .touchId))
            BiometryView(model: FakeBiometryViewModel(login: Login("_"), biometryType: .faceId))
            BiometryView(model: FakeBiometryViewModel(login: Login("_"), biometryType: .faceId, shouldDisplayProgress: true))
        }

    }
}
#endif
