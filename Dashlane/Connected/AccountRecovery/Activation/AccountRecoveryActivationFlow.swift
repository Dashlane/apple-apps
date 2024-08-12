import SwiftUI

struct AccountRecoveryActivationFlow: View {
  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  var model: AccountRecoveryActivationFlowModel

  init(model: @escaping @autoclosure () -> AccountRecoveryActivationFlowModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    NavigationView {
      AccountRecoveryActivationEmbeddedFlow(
        model: model.makeActivationViewModel {
          model.logCancel()
          dismiss()
        }, canSkip: true)
    }.navigationViewStyle(.stack)
  }
}
