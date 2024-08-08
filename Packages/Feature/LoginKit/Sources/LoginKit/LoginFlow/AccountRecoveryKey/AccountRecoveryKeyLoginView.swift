#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIComponents
  import DesignSystem
  import CoreLocalization
  import CoreSession

  struct AccountRecoveryKeyLoginView: View {

    @StateObject
    var model: AccountRecoveryKeyLoginViewModel

    @Environment(\.dismiss)
    var dismiss

    init(model: @autoclosure @escaping () -> AccountRecoveryKeyLoginViewModel) {
      self._model = .init(wrappedValue: model())
    }

    var body: some View {
      ScrollView {
        recoveryKeyView
          .navigationBarStyle(.transparent)
          .navigationTitle(L10n.Core.recoveryKeySettingsLabel)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarBackButtonHidden()
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button(
                action: {
                  dismiss()
                },
                label: {
                  Text(L10n.Core.cancel)
                    .foregroundColor(.ds.text.neutral.standard)
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
                  Text(L10n.Core.kwNext)
                    .foregroundColor(.ds.text.neutral.standard)
                })
            }
          }
      }
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }

    var recoveryKeyView: some View {
      VStack(alignment: .leading, spacing: 16) {
        Text(L10n.Core.recoveryKeyLoginTitle)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .font(
            .custom(
              GTWalsheimPro.regular.name,
              size: 28,
              relativeTo: .title
            )
            .weight(.medium)
          )
          .foregroundColor(.ds.text.neutral.catchy)
        Text(model.accountType.message)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundColor(.ds.text.neutral.standard)
          .font(.body)
          .padding(.bottom, 16)
        AccountRecoveryKeyTextField(
          recoveryKey: $model.recoveryKey, showNoMatchError: $model.showNoMatchError
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
        AccountRecoveryKeyLoginView(model: .mock())
      }
      AccountRecoveryKeyLoginView(model: .mock(recoveryKey: "NU6H-7YTZ-DQNA-2VQC-6K56-UIW1-T7YN"))
      AccountRecoveryKeyLoginView(
        model: .mock(recoveryKey: "NU6H-7YTZ-DQNA-2VQC-6K56-UIW1-T7YN", showNoMatchError: true))
    }
  }

  extension AccountType {
    fileprivate var message: String {
      switch self {
      case .masterPassword:
        return L10n.Core.recoveryKeyLoginMessage
      default:
        return L10n.Core.recoveryKeyLoginMessageNonMp
      }
    }
  }
#endif
