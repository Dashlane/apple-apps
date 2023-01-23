import DesignSystem
import SwiftUI
import UIDelight

struct PlaceholderIconView: View {
    let title: String
    let sizeType: IconStyle.SizeType

    init(title: String, sizeType: IconStyle.SizeType) {
        self.title = String(title.prefix(2)).capitalized
        self.sizeType = sizeType
    }

    var body: some View {
        Text(title)
            .foregroundColor(.ds.text.brand.quiet)
            .font(.system(size: 20.5, weight: .bold, design: .default))
            .iconStyle(sizeType: sizeType)
    }
}

struct PlaceholderIconView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            PlaceholderIconView(title: "dashlane", sizeType: .small)
            PlaceholderIconView(title: "dashlane", sizeType: .small)

        }
        .padding()
        .previewLayout(.sizeThatFits)

    }
}
