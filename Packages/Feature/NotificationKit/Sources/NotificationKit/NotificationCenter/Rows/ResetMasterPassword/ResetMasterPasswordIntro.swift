import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

public struct ResetMasterPasswordIntro: View {

  let viewModel: ResetMasterPasswordIntroViewModel

  @ScaledMetric
  private var fontSize: CGFloat = 24

  @Environment(\.dismiss) var dismiss

  public init(viewModel: ResetMasterPasswordIntroViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        Spacer()
        VStack(alignment: .leading, spacing: 16) {
          Text(L10n.Core.resetMasterPasswordInterstitialTitle)
            .font(DashlaneFont.custom(fontSize, .medium).font)
          Text(L10n.Core.resetMasterPasswordInterstitialDescription)
            .font(.body)
        }
        Spacer()
        buttons
          .buttonStyle(.designSystem(.titleOnly))
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(L10n.Core.cancel) {
            dismiss()
          }
          .foregroundColor(.ds.text.brand.standard)
        }
      }
    }
  }

  @ViewBuilder
  var buttons: some View {
    Button(L10n.Core.resetMasterPasswordInterstitialCTA) {
      viewModel.enable()
      dismiss()
    }
    Button(L10n.Core.resetMasterPasswordInterstitialSkip) {
      dismiss()
    }
    .style(intensity: .supershy)
  }
}

struct ResetMasterPasswordIntro_Previews: PreviewProvider {
  static var previews: some View {
    ResetMasterPasswordIntro(viewModel: .mock)
  }
}
