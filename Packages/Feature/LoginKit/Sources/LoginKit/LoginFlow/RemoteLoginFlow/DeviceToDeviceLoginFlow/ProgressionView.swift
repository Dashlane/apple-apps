#if canImport(UIKit)
import Foundation
import SwiftUI
import Lottie
import UIComponents

public struct ProgressionView: View {

    @Binding
    var state: ProgressionState

    public init(state: Binding<ProgressionState>) {
        self._state = state
    }

    public var body: some View {
        FullScreenScrollView {
            mainView
        }
        .padding(.horizontal, 24)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarStyle(.transparent)
        .background(.ds.background.alternate.ignoresSafeArea())
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
            case let .failed(_, completion):
                LottieView(.passwordChangerFail, loopMode: .playOnce)
                    .frame(width: 77, height: 77)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: completion)
                    }
            }
            Text(state.message)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 26,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct ProgressionView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressionView(state: .constant(.inProgress("Loading...")))
    }
}
#endif

public enum ProgressionState: Equatable {
    public static func == (lhs: ProgressionState, rhs: ProgressionState) -> Bool {
       return lhs.message == rhs.message
    }

    case inProgress(String)
    case failed(String, () -> Void)
    case completed(String, () -> Void)

    var message: String {
        switch self {
        case let .inProgress(text):
            return text
        case let .completed(text, _):
            return text
        case let .failed(text, _):
            return text
        }
    }
}
