import Foundation
import Lottie
import SwiftUI
import SwiftUILottie
import UIComponents

public struct LottieProgressionFeedbacksView: View {
  let state: ProgressionState

  public init(state: ProgressionState) {
    self.state = state
  }

  public var body: some View {
    ViewThatFits {
      ScrollView {
        mainView
      }
      mainView
    }
    .navigationBarTitleDisplayMode(.inline)
    .background(.ds.background.alternate.ignoresSafeArea())
  }

  private var mainView: some View {
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
        .textStyle(.specialty.spotlight.small)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .padding(.horizontal, 24)

  }
}

struct ProgressionView_Previews: PreviewProvider {
  static var previews: some View {
    LottieProgressionFeedbacksView(state: .inProgress("Loading..."))
  }
}

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
