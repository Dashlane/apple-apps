import SwiftUI
import SwiftTreats
import UIDelight

struct SharingEditLabel: View {
    let isInProgress: Bool

    var body: some View {
        if isInProgress {
            ProgressView()
        } else {
            if Device.isIpadOrMac {
                Text(L10n.Localizable.kwSharingItemEditAccess)
                    .foregroundColor(Color(asset: FiberAsset.accentColor))

            } else {
                Image(asset: FiberAsset.quickaction)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibilityLabel(Text(L10n.Localizable.kwSharingItemEditAccess))
                    .frame(width: 24, height: 40)
                    .foregroundColor(Color(asset: FiberAsset.accentColor))
            }
        }
    }
}

struct SharingEditLabel_Previews: PreviewProvider {
    static var previews: some View {
        Menu {
            Button("Action") {

            }
        } label: {
            SharingEditLabel(isInProgress: false)
        }
        .previewLayout(.sizeThatFits)

        Menu {
            Button("Action") {

            }
        } label: {
            SharingEditLabel(isInProgress: true)
        }
        .disabled(true)
        .previewLayout(.sizeThatFits)
    }
}
