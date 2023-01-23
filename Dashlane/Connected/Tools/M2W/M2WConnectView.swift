import DesignSystem
import CoreUserTracking
import SwiftUI
import UIComponents
import UIDelight

struct M2WConnectView: View {

    enum Action {
        case didTapCancel
        case didTapDone
    }

    let completion: (Action) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(asset: FiberAsset.m2wConnect)
                .padding(.bottom, 65)
                .fiberAccessibilityLabel(Text("dashlane.com/addweb"))

            Text(L10n.Localizable.m2WConnectScreenTitle)
                .frame(maxWidth: 400)
                .font(DashlaneFont.custom(28, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text(L10n.Localizable.m2WConnectScreenSubtitle)
                .frame(maxWidth: 400)
                .font(.body.weight(.light))
                .foregroundColor(.ds.text.neutral.standard)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationBarBackButtonHidden(true)
        .navigationBarStyle(.transparent)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { completion(.didTapCancel) }, title: L10n.Localizable.m2WConnectScreenCancel)
                .foregroundColor(.ds.text.brand.standard)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { completion(.didTapDone) }, label: {
                Text(L10n.Localizable.m2WConnectScreenDone)
                    .bold()
            })
            .foregroundColor(.ds.text.brand.standard)
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
