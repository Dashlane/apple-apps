import CoreLocalization
import Foundation
import SwiftUI

struct AnnouncementCloseButton: View {

  let dismiss: () -> Void

  var body: some View {
    Button(
      action: { self.dismiss() },
      label: {
        Image.ds.action.close.outlined
          .resizable()
          .renderingMode(.template)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .padding(6)
          .background(Circle().foregroundStyle(Color.ds.container.agnostic.neutral.standard))
          .frame(width: 30, height: 30)
      }
    ).padding()
      .accessibilityLabel(Text(CoreL10n.kwButtonClose))
  }
}
