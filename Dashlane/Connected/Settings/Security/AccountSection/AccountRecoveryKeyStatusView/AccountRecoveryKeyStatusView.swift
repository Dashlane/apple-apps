import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI

struct AccountRecoveryKeyStatusView: View {

  @StateObject
  var model: AccountRecoveryKeyStatusViewModel

  init(model: @autoclosure @escaping () -> AccountRecoveryKeyStatusViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {

    switch model.status {
    case .loading:
      AccountRecoveryKeyStatus {
        ProgressView()
          .progressViewStyle(.indeterminate)
      }
    case .error:
      AccountRecoveryKeyStatus {
        Image.ds.feedback.fail.outlined
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(Color.ds.text.danger.quiet)
      }
    case .noInternet:
      AccountRecoveryKeyStatus {
        Image.ds.noNetwork.outlined
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(Color.ds.text.danger.quiet)
      }
    case let .keySatus(isEnabled):
      NavigationLink(
        destination: {
          AccountRecoveryKeyStatusDetailView(
            model: model.makeAccountRecoveryKeyStatusDetailViewModel(isEnabled: isEnabled))
        },
        label: {
          AccountRecoveryKeyStatus {
            Text(
              isEnabled
                ? L10n.Localizable.recoveryKeySettingsOnLabel
                : L10n.Localizable.recoveryKeySettingsOffLabel
            )
            .foregroundStyle(Color.ds.text.neutral.quiet)
          }
        }
      ).onAppear {
        Task {
          await model.fetchStatus()
        }
      }
    }
  }

  func errorView(_ image: Image) -> some View {
    HStack {
      Text(CoreL10n.recoveryKeySettingsLabel)
        .foregroundStyle(Color.ds.text.neutral.standard)
      Spacer()
      image
        .resizable()
        .frame(width: 16, height: 16)
        .foregroundStyle(Color.ds.text.danger.quiet)
    }
  }
}

private struct AccountRecoveryKeyStatus<Content: View>: View {
  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    HStack {
      Text(CoreL10n.recoveryKeySettingsLabel)
        .foregroundStyle(Color.ds.text.neutral.standard)
      Spacer()
      content()
    }
  }
}

struct AccountRecoveryKeyStatusView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryKeyStatusView(
      model: AccountRecoveryKeyStatusViewModel(
        session: .mock,
        appAPIClient: .fake,
        userAPIClient: .fake,
        reachability: .mock(),
        recoveryKeyStatusDetailViewModelFactory: AccountRecoveryKeyStatusDetailViewModel.Factory({
          _ in
          AccountRecoveryKeyStatusDetailViewModel.mock
        })))
    AccountRecoveryKeyStatusView(
      model: AccountRecoveryKeyStatusViewModel(
        session: .mock,
        appAPIClient: .fake,
        userAPIClient: .fake, reachability: .mock(),
        recoveryKeyStatusDetailViewModelFactory: AccountRecoveryKeyStatusDetailViewModel.Factory({
          _ in
          AccountRecoveryKeyStatusDetailViewModel.mock
        })))
  }
}
