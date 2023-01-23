import SwiftUI
import UIComponents

struct SendingShareView: View {
    enum Step {
        case inProgress
        case success
    }

    let step: Step

    var body: some View {
        ZStack {
            switch step {
            case .success:
                LottieView(LottieAsset.loadingAnimationCompletion, loopMode: .playOnce)
                    .frame(width: 180, height: 180)
                    .padding(60)
                    .overlay(alignment: .bottom) {
                        Text(L10n.Localizable.kwSharingSuccess)
                            .alignmentGuide(.bottom, to: .top)
                            .font(.title)
                            .multilineTextAlignment(.center)
                    }

            case .inProgress:
                LottieView(LottieAsset.loadingAnimationProgress)
                    .frame(width: 172, height: 172)
                    .padding(30)
                    .overlay {
                        Image(asset: FiberAsset.sharingPaywall)
                            .foregroundColor(.ds.border.neutral.quiet.idle)
                            .padding(50)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: step)
        .navigationTitle(L10n.Localizable.kwShareItem)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(step == .inProgress)
    }
}

struct ShareProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SendingShareView(step: .inProgress)
            .previewDisplayName("Progress")
        SendingShareView(step: .success)
            .previewDisplayName("Success")
    }
}
