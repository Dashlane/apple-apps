import Foundation
import SwiftUI
import UIComponents

struct MigrationProgressView: View {

    @ObservedObject
    var model: MigrationProgressViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Group {
                if model.isProgress {
                    LottieView(.passwordChangerLoading)
                } else {
                    if model.isSuccess {
                        LottieView(.passwordChangerSuccess, loopMode: .playOnce)
                    } else {
                        LottieView(.passwordChangerFail, loopMode: .playOnce)
                    }
                }
            }
            .frame(width: 64, height: 64, alignment: .center)
            Text(model.progressionText)
                .font(DashlaneFont.custom(26, .bold).font)
            Text(L10n.Localizable.changingMasterPasswordSubtitle)
                .font(.body)
                .foregroundColor(Color(asset: FiberAsset.dashlaneTextGrey))
                .hidden(!model.isProgress)
        }.alert(item: $model.currentAlert, content: makeAlert)
    }

    private func makeAlert(_ alert: MigrationProgressViewModel.MigrationAlert) -> Alert {
        switch alert.reason {
        case .masterPasswordSuccess:
            return makeMasterPasswordAlert(dismissAction: alert.dismissAction)
        case .failure:
            return makeFailureAlert(dismissAction: alert.dismissAction)
        }
    }

    private func makeMasterPasswordAlert(dismissAction: @escaping () -> Void) -> Alert {
        return Alert(title: Text(L10n.Localizable.changeMasterPasswordReaskPrompt),
                     message: Text(""),
                     dismissButton: Alert.Button.default(Text(L10n.Localizable.kwButtonOk), action: dismissAction))
    }

    private func makeFailureAlert(dismissAction: @escaping () -> Void) -> Alert {
        return Alert(title: Text(L10n.Localizable.changeMasterPasswordErrorTitle),
                     message: Text(L10n.Localizable.changeMasterPasswordErrorMessage),
                     dismissButton: Alert.Button.default(Text(L10n.Localizable.kwButtonOk), action: dismissAction))
    }
}

extension MigrationProgressView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .hidden()
    }
}

struct MigrationProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MigrationProgressView(model: MigrationProgressViewModel(type: .masterPasswordToMasterPassword,
                                                                activityReporter: .fake,
                                                                completion: {_ in }))
        MigrationProgressView(model: MigrationProgressViewModel(type: .masterPasswordToMasterPassword,
                                                                activityReporter: .fake,
                                                                isProgress: false,
                                                                completion: {_ in }))
        MigrationProgressView(model: MigrationProgressViewModel(type: .masterPasswordToMasterPassword,
                                                                activityReporter: .fake,
                                                                isProgress: false,
                                                                isSuccess: false,
                                                                completion: {_ in }))
    }
}
