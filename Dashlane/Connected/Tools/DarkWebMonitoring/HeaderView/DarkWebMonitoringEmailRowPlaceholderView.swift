import DesignSystem
import Foundation
import SwiftUI
import UIDelight

struct DarkWebMonitoringEmailRowPlaceholderView: View {
  let example = "_"

  var body: some View {
    HStack {
      Thumbnail.User.single(nil)
        .controlSize(.small)
      Text(example)
        .font(.body)
        .foregroundColor(.ds.text.neutral.quiet)
        .padding(.leading, 16)
      Spacer()
    }
    .padding(.horizontal, 16)
    .background(Color.clear)
    .frame(maxWidth: .infinity)
  }
}

struct DarkWebMonitoringEmailRowPlaceholderView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      DarkWebMonitoringEmailRowPlaceholderView()
    }.previewLayout(.sizeThatFits)
  }
}
