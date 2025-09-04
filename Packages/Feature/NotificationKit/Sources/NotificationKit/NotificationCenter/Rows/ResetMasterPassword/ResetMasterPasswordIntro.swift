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
          Text(CoreL10n.resetMasterPasswordInterstitialTitle)
            .textStyle(.title.section.large)
          Text(CoreL10n.resetMasterPasswordInterstitialDescription)
            .textStyle(.body.standard.regular)
        }
        Spacer()
        buttons
          .buttonStyle(.designSystem(.titleOnly))
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            dismiss()
          }
          .foregroundStyle(Color.ds.text.brand.standard)
        }
      }
    }
  }

  @ViewBuilder
  var buttons: some View {
    Button(CoreL10n.resetMasterPasswordInterstitialCTA) {
      viewModel.enable()
      dismiss()
    }
    Button(CoreL10n.resetMasterPasswordInterstitialSkip) {
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
