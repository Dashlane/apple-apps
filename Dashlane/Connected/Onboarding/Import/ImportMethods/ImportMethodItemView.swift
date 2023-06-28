import DesignSystem
import SwiftUI
import UIDelight

struct ImportMethodItemView: View {

    let importMethod: ImportMethod

    var body: some View {
        HStack(alignment: .center, spacing: 18.0) {
            importMethod.image
                .foregroundColor(Color(asset: FiberAsset.dashGreenCopy))
                .fiberAccessibilityHidden(true)

            Text(importMethod.title)
                .foregroundColor(.ds.text.neutral.catchy)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fiberAccessibilityElement(children: .combine)
    }
}

struct ImportMethodItemView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Group {
                ImportMethodItemView(importMethod: .chrome)
                ImportMethodItemView(importMethod: .dash)
                ImportMethodItemView(importMethod: .keychain)
                ImportMethodItemView(importMethod: .manual)
            }
        }.previewLayout(.sizeThatFits)
    }
}
