import DesignSystem
import SwiftUI
import UIDelight

struct OpenWebsiteMenuButton: View {
  let url: URL

  var body: some View {
    Button {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } label: {
      HStack {
        Text(L10n.Localizable.openWebsite)
        Image.ds.action.openExternalLink.outlined
      }
    }
  }
}

struct OpenWebsiteMenuButton_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      OpenWebsiteMenuButton(url: URL(string: "_")!)
        .foregroundColor(.ds.text.neutral.catchy)
    }
    .padding()
    .background(Color.ds.background.default)
    .previewLayout(.sizeThatFits)
  }
}
