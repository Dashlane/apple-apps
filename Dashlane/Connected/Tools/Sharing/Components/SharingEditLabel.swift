import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight

struct SharingEditLabel: View {
  let isInProgress: Bool

  var body: some View {
    if isInProgress {
      ProgressView()
    } else {
      if Device.is(.pad, .mac, .vision) {
        Text(L10n.Localizable.kwSharingItemEditAccess)
          .foregroundStyle(Color.ds.text.brand.standard)
      } else {
        Image.ds.action.more.outlined
          .resizable()
          .aspectRatio(contentMode: .fit)
          .accessibilityLabel(Text(L10n.Localizable.kwSharingItemEditAccess))
          .frame(width: 24, height: 40)
          .foregroundStyle(Color.ds.text.brand.quiet)
      }
    }
  }
}

#Preview {
  Menu {
    Button("Action") {}
  } label: {
    SharingEditLabel(isInProgress: false)
  }
}

#Preview {
  Menu {
    Button("Action") {}
  } label: {
    SharingEditLabel(isInProgress: true)
  }
  .disabled(true)
}
