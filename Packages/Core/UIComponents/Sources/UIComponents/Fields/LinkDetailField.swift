import DesignSystem
import SwiftUI
import UIDelight

public struct LinkDetailField: DetailField {
  let title: String
  var onTap: (() -> Void)

  public init(title: String, onTap: @escaping () -> Void) {
    self.title = title
    self.onTap = onTap
  }

  public var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.ds.text.neutral.standard)
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.ds.text.neutral.quiet)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .onTapWithFeedback {
      self.onTap()
    }
  }
}

struct LinkDetailField_Previews: PreviewProvider {
  static var previews: some View {
    LinkDetailField(title: "website", onTap: {})
  }
}
