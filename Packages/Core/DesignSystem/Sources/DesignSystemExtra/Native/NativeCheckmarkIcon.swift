import SwiftUI

public struct NativeCheckmarkIcon: View {
  public let isChecked: Bool

  public init(isChecked: Bool) {
    self.isChecked = isChecked
  }

  public var body: some View {
    if isChecked {
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(Color.ds.text.brand.standard)
    } else {
      Image(systemName: "circle")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .fontWeight(.thin)
        .foregroundStyle(Color.ds.border.neutral.standard.idle)
    }
  }
}

#Preview {
  NativeCheckmarkIcon(isChecked: false)
    .frame(width: 44)
  NativeCheckmarkIcon(isChecked: true)
    .frame(width: 44)
}
