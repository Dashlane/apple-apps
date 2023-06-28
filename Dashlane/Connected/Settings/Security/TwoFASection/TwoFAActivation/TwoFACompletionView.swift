import Foundation
import SwiftUI
import CoreSession
import CoreFeature
import UIComponents
import DashTypes
import DesignSystem
import LoginKit
import CoreLocalization

struct TwoFACompletionView: View {

    @StateObject
    var model: TwoFACompletionViewModel

    init(model: @autoclosure @escaping () -> TwoFACompletionViewModel) {
        self._model = .init(wrappedValue: model())
    }

    private let bulletPoint = "\u{2022} "

    var body: some View {
        ZStack {
            switch model.state {
            case .inProgress:
                ProgressionView(state: $model.progressState)
            case let .success(completion):
                successView(completion: completion)
            case let .failure(error):
                errorView(for: error)
            }
        }
        .animation(.default, value: model.state)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(L10n.Localizable.twofaStepsNavigationTitle)
        .reportPageAppearance(.settingsSecurityTwoFactorAuthenticationEnableSuccessConfirmation)
    }

    func successView(completion: @escaping () -> Void) -> some View {
        ScrollView {
            mainView
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationBarButton(action: completion, title: L10n.Localizable.kwSkip)
                    }
                }
        }
        .overlay(
            VStack {
                Spacer()
                RoundedButton(L10n.Localizable.twofaSuccessCta, action: {
                    UIApplication.shared.open(URLScheme.authenticator.url)
                    completion()
                })
                .roundedButtonLayout(.fill)
            }
            .padding(24)
        )
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 44) {
            Image(asset: FiberAsset.autofill)
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.Localizable.twofaSuccessTitle)
                    .font(.custom(GTWalsheimPro.regular.name,
                                  size: 28,
                                  relativeTo: .title)
                        .weight(.medium))
                    .foregroundColor(.ds.text.neutral.catchy)

                VStack(alignment: .leading) {
                    Text(L10n.Localizable.twofaSuccessSubtitle)
                    VStack(alignment: .leading) {
                        Text(bulletPoint + L10n.Localizable.twofaSuccessMessage1)
                        Text(bulletPoint + L10n.Localizable.twofaSuccessMessage2)
                    }.padding(.leading)
                }
                .foregroundColor(.ds.text.neutral.standard)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .padding(.bottom, 60)
    }

    func errorView(for error: OTPError) -> some View {
        switch error {
        case .noInternet:
            return FeedbackView(title: L10n.Localizable.twofaActivationNoInternetErrorTitle,
                               message: L10n.Localizable.twofaActivationNoInternetErrorMessage,
                                primaryButton: (CoreLocalization.L10n.Core.modalTryAgain, {
               Task {
                   await model.start()
               }
            }),
                                secondaryButton: (CoreLocalization.L10n.Core.cancel, {
                model.completion()
            }))
        case .unknown:
           return FeedbackView(title: L10n.Localizable.twofaActivationErrorTitle,
                               message: L10n.Localizable.twofaActivationErrorMessage, primaryButton: (L10n.Localizable.twofaActivationErrorCta, {
               model.completion()
            }))
        }
    }
}

