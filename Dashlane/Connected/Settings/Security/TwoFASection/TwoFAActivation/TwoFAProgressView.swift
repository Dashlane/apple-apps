import Foundation
import SwiftUI
import Lottie
import UIComponents

struct TwoFAProgressView: View {

    enum State {
        case inProgress(String)
        case completed(String, () -> Void)

        var message: String {
            switch self {
            case let .inProgress(text):
                return text
            case let .completed(text, _):
                return text
            }
        }
    }

    @Binding
    var state: State

    var body: some View {
        FullScreenScrollView {
            mainView
        }
        .padding(.horizontal, 24)
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .navigationBarTitleDisplayMode(.inline)
    }

    var mainView: some View {
        VStack(spacing: 45) {
            switch state {
            case .inProgress:
                LottieView(.passwordChangerLoading)
                    .frame(width: 77, height: 77)
            case let .completed(_, completion):
                LottieView(.passwordChangerSuccess, loopMode: .playOnce)
                    .frame(width: 77, height: 77)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: completion)
                    }
            }
            Text(state.message)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct TwoFAProgressView_Previews: PreviewProvider {
    static var previews: some View {
        TwoFAProgressView(state: .constant(.inProgress(L10n.Localizable.twofaActivationProgressMessage)))
    }
}
