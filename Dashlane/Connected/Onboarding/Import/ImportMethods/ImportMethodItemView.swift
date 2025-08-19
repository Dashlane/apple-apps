import DesignSystem
import SwiftUI
import UIDelight

struct ImportMethodItemView: View {

  let importMethod: LegacyImportMethod

  var body: some View {
    HStack(alignment: .center, spacing: 18.0) {
      importMethod.image
        .foregroundStyle(Color.ds.text.brand.standard)
        .fiberAccessibilityHidden(true)

      Text(importMethod.title)
        .foregroundStyle(Color.ds.text.neutral.catchy)
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
        ImportMethodItemView(importMethod: .manual)
      }
    }.previewLayout(.sizeThatFits)
  }
}
