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
      if Device.isIpadOrMac {
        Text(L10n.Localizable.kwSharingItemEditAccess)
          .foregroundColor(.ds.text.brand.standard)
      } else {
        Image.ds.action.more.outlined
          .resizable()
          .aspectRatio(contentMode: .fit)
          .accessibilityLabel(Text(L10n.Localizable.kwSharingItemEditAccess))
          .frame(width: 24, height: 40)
          .foregroundColor(.ds.text.brand.quiet)
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
