import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import SwiftUILottie
import UIComponents

struct MigrationProgressView: View {

  @StateObject
  var model: MigrationProgressViewModel

  init(model: @escaping @autoclosure () -> MigrationProgressViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      Group {
        if model.isProgress {
          LottieView(.passwordChangerLoading)
        } else {
          if model.isSuccess {
            LottieView(.passwordChangerSuccess, loopMode: .playOnce)
          } else {
            LottieView(.passwordChangerFail, loopMode: .playOnce)
          }
        }
      }
      .frame(width: 64, height: 64, alignment: .center)

      VStack(alignment: .center, spacing: 8) {
        Text(model.progressionText)
          .textStyle(.title.section.medium)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        if model.isProgress {
          Text(L10n.Localizable.changingMasterPasswordSubtitle)
            .textStyle(.body.standard.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
      }
    }
    .padding()
    .multilineTextAlignment(.center)
    .alert(item: $model.currentAlert, content: makeAlert)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .ignoresSafeArea()
    .onChange(of: model.progressionText) { _, progression in
      UIAccessibility.fiberPost(.announcement, argument: progression)
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      model.start()
    }
  }

  private func makeAlert(_ alert: MigrationProgressViewModel.MigrationAlert) -> Alert {
    switch alert.reason {
    case .masterPasswordSuccess:
      return makeMasterPasswordAlert(dismissAction: alert.dismissAction)
    case .failure:
      return makeFailureAlert(dismissAction: alert.dismissAction)
    }
  }

  private func makeMasterPasswordAlert(dismissAction: @escaping () -> Void) -> Alert {
    return Alert(
      title: Text(L10n.Localizable.changeMasterPasswordReaskPrompt),
      message: Text(""),
      dismissButton: Alert.Button.default(Text(CoreL10n.kwButtonOk), action: dismissAction))
  }

  private func makeFailureAlert(dismissAction: @escaping () -> Void) -> Alert {
    return Alert(
      title: Text(L10n.Localizable.changeMasterPasswordErrorTitle),
      message: Text(L10n.Localizable.changeMasterPasswordErrorMessage),
      dismissButton: Alert.Button.default(Text(CoreL10n.kwButtonOk), action: dismissAction))
  }
}

#Preview("In Progress") {
  MigrationProgressView(model: .mock())
}

#Preview("Complete") {
  MigrationProgressView(model: .mock(complete: true))
}
