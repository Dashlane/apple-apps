import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct PurchaseEmptyView: View {

  let cancel: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 30) {
      DS.ExpressiveIcon(.ds.feedback.fail.outlined)
        .controlSize(.large)
        .style(mood: .neutral, intensity: .quiet)
        .scaleEffect(1.4)
        .fiberAccessibilityHidden(true)
      VStack(alignment: .leading, spacing: 10) {
        Text(CoreL10n.plansEmptystateTitle)
          .textStyle(.title.section.large)
        Text(CoreL10n.plansEmptystateSubtitle)
          .textStyle(.body.standard.regular)
      }
    }
    .multilineTextAlignment(.leading)
    .padding(.horizontal, 24)
    .frame(maxHeight: .infinity, alignment: .center)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        leadingButton
      }
    }
  }

  private var leadingButton: some View {
    Button(CoreL10n.cancel) {
      self.cancel()
    }

  }
}

struct PurchaseEmptyView_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseEmptyView(cancel: { print("Cancel") })
  }
}
