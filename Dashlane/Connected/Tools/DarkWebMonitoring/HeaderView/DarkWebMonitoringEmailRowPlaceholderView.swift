import DesignSystem
import Foundation
import SwiftUI
import UIDelight

struct DarkWebMonitoringEmailRowPlaceholderView: View {
  let example = "_"

  var body: some View {
    HStack(spacing: 12) {
      Thumbnail.User.single(nil)
      Text(example)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct DarkWebMonitoringEmailRowPlaceholderView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      DarkWebMonitoringEmailRowPlaceholderView()
    }.previewLayout(.sizeThatFits)
  }
}
