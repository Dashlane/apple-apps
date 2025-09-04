import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI

struct DeviceTransferPassphraseView: View {

  @StateObject
  var model: DeviceTransferPassphraseViewModel

  var body: some View {
    ZStack {
      if model.isLoading {
        LottieProgressionFeedbacksView(state: model.progressState)
      } else {
        mainview
      }
    }
    .animation(.default, value: model.isLoading)
    .loginAppearance()
  }

  var mainview: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(CoreL10n.Mpless.D2d.Universal.Untrusted.passphraseTitle)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(CoreL10n.Mpless.D2d.Universal.Untrusted.passphraseMessage)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      VStack(alignment: .leading, spacing: 24) {
        ForEach(model.words) { word in
          HStack {
            Text(word)
              .textStyle(.body.standard.monospace)
              .foregroundStyle(Color.ds.text.neutral.catchy)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }.padding(24)
        .background(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.ds.container.agnostic.neutral.supershy)
        )
      Spacer()
    }
    .padding(24)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .navigationTitle(CoreL10n.deviceToDeviceNavigationTitle)
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(
          CoreL10n.Mpless.D2d.Universal.Untrusted.passphraseCancelCta,
          action: {
            model.cancel()
          }
        )
        .foregroundStyle(Color.ds.text.brand.standard)
      }
    }
  }
}

struct PassphraseView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DeviceTransferPassphraseView(model: .mock)
    }
  }
}
