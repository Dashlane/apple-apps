import CoreLocalization
import DesignSystem
import SwiftUI
import UserTrackingFoundation

struct ChangeLoginEmailFailureView: View {
  typealias L10n = CoreL10n.ChangeLoginEmail

  enum Completion {
    case tryAgain
    case cancel
  }

  let completion: (Completion) -> Void

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      DS.ExpressiveIcon(.ds.feedback.fail.outlined)
        .controlSize(.extraLarge)
        .style(mood: .danger, intensity: .quiet)

      VStack(spacing: 8) {
        Text(L10n.somethingWentWrongTitle)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)

        Text(L10n.somethingWentWrongMessage)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()

      VStack {
        Button(L10n.wrongTokenCta) {
          completion(.tryAgain)
        }
        .buttonStyle(.designSystem(.titleOnly))

        Button(L10n.cancel, role: .cancel) {
          completion(.cancel)
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(mood: .brand, intensity: .quiet)
      }
    }
    .navigationBarBackButtonHidden()
    .padding()
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }
}

#Preview {
  ChangeLoginEmailFailureView(completion: { _ in })
}
