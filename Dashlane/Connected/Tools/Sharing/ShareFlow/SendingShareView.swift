import SwiftUI
import UIComponents

struct SendingShareView: View {

  @Binding
  var hasSucceed: Bool

  var body: some View {
    ZStack {
      if hasSucceed {
        LottieView(LottieAsset.loadingAnimationCompletion, loopMode: .playOnce)
          .frame(width: 180, height: 180)
          .padding(60)
          .overlay(alignment: .bottom) {
            Text(L10n.Localizable.kwSharingSuccess)
              .fiberAccessibilityAnnouncement(L10n.Localizable.kwSharingSuccess)
              .alignmentGuide(.bottom, to: .top)
              .font(.title)
              .multilineTextAlignment(.center)
          }
      } else {
        LottieView(LottieAsset.loadingAnimationProgress)
          .frame(width: 172, height: 172)
          .padding(30)
          .overlay {
            Image.ds.group.outlined
              .foregroundColor(.ds.border.neutral.quiet.idle)
              .padding(50)
          }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .animation(.easeInOut, value: hasSucceed)
    .navigationTitle(L10n.Localizable.kwShareItem)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .interactiveDismissDisabled(!hasSucceed)
  }
}

struct ShareProgressView_Previews: PreviewProvider {
  static var previews: some View {
    SendingShareView(hasSucceed: .init(get: { true }, set: { _ in }))
      .previewDisplayName("Progress")
    SendingShareView(hasSucceed: .init(get: { false }, set: { _ in }))
      .previewDisplayName("Success")
  }
}
