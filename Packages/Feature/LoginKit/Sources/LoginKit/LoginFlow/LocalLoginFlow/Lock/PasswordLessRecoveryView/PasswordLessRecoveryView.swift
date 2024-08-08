#if canImport(UIKit)

  import SwiftUI
  import DashTypes
  import CoreSession
  import CoreLocalization
  import DesignSystem
  import UIComponents

  public struct PasswordLessRecoveryView: View {
    enum Flow: String, Identifiable {
      case recovery
      case deviceToDevice

      var id: String {
        return rawValue
      }
    }

    let l10n = L10n.Core.Unlock.PasswordlessRecovery.self

    @StateObject
    var model: PasswordLessRecoveryViewModel

    @State
    var displayedFlow: Flow?

    public init(model: @autoclosure @escaping () -> PasswordLessRecoveryViewModel) {
      self._model = .init(wrappedValue: model())
    }

    public var body: some View {
      VStack {
        VStack(alignment: .leading, spacing: 33) {
          if model.recoverFromFailure {
            Image.ds.feedback.fail.outlined
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.ds.text.danger.quiet)
              .frame(width: 62)
          }

          description
        }
        Spacer()
        actions
      }
      .padding(.top, 51)
      .padding(.bottom, 35)
      .padding(.horizontal, 24)
      .loginAppearance()
      .fullScreenCover(item: $displayedFlow) { flow in
        switch flow {
        case .deviceToDevice:
          DeviceTransferQRCodeFlow(
            model: model.makeDeviceToDeviceLoginFlowViewModel(),
            progressState: .constant(.inProgress("")))
        case .recovery:
          NavigationView {
            AccountRecoveryKeyLoginFlow(model: model.makeAccountRecoveryKeyLoginFlowModel())
          }
        }
      }
      .navigationBarBackButtonHidden(true)
    }
    var description: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text(l10n.title)
          .textStyle(.title.section.large)

        VStack(alignment: .leading, spacing: 20) {
          Text(l10n.message)
            .textStyle(.body.reduced.regular)
          Text(l10n.alternativeMessage)
            .textStyle(.body.reduced.regular)
        }
      }
    }

    var actions: some View {
      VStack(spacing: 8) {
        Button(L10n.Core.Unlock.PasswordlessRecovery.goToLoginButton) {
          model.logout()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(mood: .brand, intensity: .catchy)

        Button(L10n.Core.Unlock.PasswordlessRecovery.contactUserSupportButton) {
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(mood: .brand, intensity: .quiet)
      }

    }
  }

  struct PasswordLessRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
      PasswordLessRecoveryView(model: .mock(recoverFromFailure: false))
        .previewDisplayName("Regular")
      PasswordLessRecoveryView(model: .mock(recoverFromFailure: true))
        .previewDisplayName("from Failure")
    }
  }
#endif
