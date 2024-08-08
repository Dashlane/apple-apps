import CoreLocalization
import Foundation
import SwiftUI
import UIComponents

struct PurchaseEmptyView: View {

  let cancel: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Image(asset: Asset.errorState)
        .foregroundColor(.ds.text.neutral.catchy)
        .scaleEffect(1.4)
        .fiberAccessibilityHidden(true)
      Text(L10n.Core.plansEmptystateTitle)
        .font(DashlaneFont.custom(24, .bold).font)
      Text(L10n.Core.plansEmptystateSubtitle)
        .font(DashlaneFont.custom(16, .regular).font)
    }
    .padding(.horizontal, 24)
    .frame(maxHeight: .infinity, alignment: .center)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        leadingButton
      }
    }
  }

  private var leadingButton: some View {
    NavigationBarButton(L10n.Core.cancel) {
      self.cancel()
    }

  }
}

struct PurchaseEmptyView_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseEmptyView(cancel: { print("Cancel") })
  }
}
