import SwiftUI

struct FieldSmallLabel: View {
  private let title: String

  init(_ title: String) {
    self.title = title
  }

  var body: some View {
    Text(title)
      .textStyle(.body.helper.regular)
      ._foregroundStyle(.text)
  }
}

#Preview {
  FieldSmallLabel("Small Field Label")
    .style(intensity: .quiet)
}
