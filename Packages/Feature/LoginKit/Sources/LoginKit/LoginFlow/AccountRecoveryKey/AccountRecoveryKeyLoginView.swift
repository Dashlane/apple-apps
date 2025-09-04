import CoreLocalization
import CoreSession
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct AccountRecoveryKeyLoginView: View {

  @StateObject
  var model: AccountRecoveryKeyLoginViewModel

  @Binding
  var showNoMatchError: Bool

  @Environment(\.dismiss)
  var dismiss

  init(
    model: @autoclosure @escaping () -> AccountRecoveryKeyLoginViewModel,
    showNoMatchError: Binding<Bool>
  ) {
    self._model = .init(wrappedValue: model())
    self._showNoMatchError = showNoMatchError
  }

  var body: some View {
    ScrollView {
      recoveryKeyView
        .navigationTitle(CoreL10n.recoveryKeySettingsLabel)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(
              action: {
                dismiss()
              },
              label: {
                Text(CoreL10n.cancel)
                  .foregroundStyle(Color.ds.text.neutral.standard)
              }
            )
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(
              action: {
                Task {
                  await model.validate()
                }
              },
              label: {
                Text(CoreL10n.kwNext)
                  .foregroundStyle(Color.ds.text.neutral.standard)
              })
          }
        }
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  var recoveryKeyView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(CoreL10n.recoveryKeyLoginTitle)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(model.accountType.message)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .textStyle(.body.standard.regular)
        .padding(.bottom, 16)
      AccountRecoveryKeyTextField(
        recoveryKey: $model.recoveryKey, showNoMatchError: $showNoMatchError
      )
      .onSubmit {
        Task {
          await model.validate()
        }
      }
      Spacer()
    }.padding(.all, 24)
      .padding(.bottom, 24)

  }
}

struct AccountRecoveryKeyLoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AccountRecoveryKeyLoginView(model: .mock(), showNoMatchError: .constant(false))
    }
    AccountRecoveryKeyLoginView(
      model: .mock(recoveryKey: "NU6H-7YTZ-DQNA-2VQC-6K56-UIW1-T7YN"),
      showNoMatchError: .constant(false))
    AccountRecoveryKeyLoginView(
      model: .mock(recoveryKey: "NU6H-7YTZ-DQNA-2VQC-6K56-UIW1-T7YN"),
      showNoMatchError: .constant(true))
  }
}

extension AccountType {
  fileprivate var message: String {
    switch self {
    case .masterPassword:
      return CoreL10n.recoveryKeyLoginMessage
    default:
      return CoreL10n.recoveryKeyLoginMessageNonMp
    }
  }
}
