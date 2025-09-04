import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI

public struct BiometricQuickSetupView: View {
  let l10n = CoreL10n.PasswordlessAccountCreation.Biometry.self

  public enum CompletionResult {
    case useBiometry
    case skip
  }

  let biometry: Biometry
  let completion: (CompletionResult) -> Void

  public init(biometry: Biometry, completion: @escaping (CompletionResult) -> Void) {
    self.biometry = biometry
    self.completion = completion
  }

  public var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 58) {
        Image(biometry: biometry)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(Color.ds.text.brand.standard)
          .frame(width: 60)
        description
      }
      Spacer()
      actions
    }
    .padding(.top, 51)
    .padding(.bottom, 35)
    .padding(.horizontal, 24)
    .loginAppearance()
    .navigationTitle(l10n.navigationTitle)
  }
  var description: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(l10n.title(biometry.displayableName))
        .textStyle(.title.section.large)
      Text(l10n.message(biometry.displayableName))
        .textStyle(.body.standard.regular)
    }
  }

  var actions: some View {
    VStack(spacing: 8) {
      Button(l10n.useButton(biometry.displayableName)) {
        completion(.useBiometry)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .catchy)

      Button(l10n.skipButton) {
        completion(.skip)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .quiet)
    }
  }
}

struct BiometricQuickSetupView_Previews: PreviewProvider {
  static var previews: some View {
    BiometricQuickSetupView(biometry: .faceId) { _ in

    }
  }
}
