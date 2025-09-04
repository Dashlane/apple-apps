import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

struct M2WConnectView: View {

  enum Action {
    case didTapCancel
    case didTapDone
  }

  let completion: (Action) -> Void

  var body: some View {
    VStack(alignment: .center, spacing: 8) {
      Image(.Onboarding.m2WConnect)
        .padding(.bottom, 65)
        .fiberAccessibilityLabel(Text("dashlane.com/addweb"))

      Text(L10n.Localizable.m2WConnectScreenTitle)
        .frame(maxWidth: 400)
        .textStyle(.specialty.spotlight.small)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)

      Text(L10n.Localizable.m2WConnectScreenSubtitle)
        .frame(maxWidth: 400)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(L10n.Localizable.m2WConnectScreenCancel) {
        completion(.didTapCancel)
      }
      .foregroundStyle(Color.ds.text.brand.standard)
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      Button(
        action: { completion(.didTapDone) },
        label: {
          Text(L10n.Localizable.m2WConnectScreenDone)
            .bold()
        }
      )
      .foregroundStyle(Color.ds.text.brand.standard)
    }
  }
}

struct M2WConnectView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(deviceRange: .some([.iPhone8, .iPhone11, .iPadPro])) {
      M2WConnectView(completion: { _ in })
    }
  }
}
