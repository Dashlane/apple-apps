import DesignSystem
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
                    .foregroundColor(.ds.text.brand.standard)
            } else {
                Image.ds.action.more.outlined
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibilityLabel(Text(L10n.Localizable.kwSharingItemEditAccess))
                    .frame(width: 24, height: 40)
                    .foregroundColor(.ds.text.brand.quiet)
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
