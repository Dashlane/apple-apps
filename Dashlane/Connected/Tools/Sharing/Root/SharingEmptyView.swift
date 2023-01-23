import SwiftUI
import DesignSystem

struct SharingEmptyView: View {
    let showText: Bool

    init(showText: Bool = true) {
        self.showText = showText
    }

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Image(asset: FiberAsset.sharingPaywall)
            if showText {
                Text(L10n.Localizable.emptySharingListText)
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }

        }.foregroundColor(.ds.text.neutral.quiet)
    }
}

struct SharingEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        SharingEmptyView()
        SharingEmptyView(showText: false)
    }
}
