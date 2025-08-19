import CoreLocalization
import DesignSystem
import SwiftUI
import UserTrackingFoundation

struct ChangeLoginEmailSuccessView: View {
  typealias L10n = CoreL10n.ChangeLoginEmail

  let completion: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      DS.ExpressiveIcon(.ds.feedback.success.outlined)
        .controlSize(.extraLarge)
        .style(mood: .positive, intensity: .quiet)

      VStack(spacing: 8) {
        Text(L10n.successTitle)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)

        Text(L10n.successMessage)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()

      Button(L10n.successCta) {
        completion()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .fixedSize(horizontal: false, vertical: true)
    }
    .padding()
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden()
  }
}

#Preview {
  ChangeLoginEmailSuccessView(completion: {})
}
