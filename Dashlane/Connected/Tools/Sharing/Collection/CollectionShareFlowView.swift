import CoreLocalization
import CoreSharing
import SwiftUI
import UIDelight
import VaultKit

struct CollectionShareFlowView: View {
  @StateObject
  var model: CollectionShareFlowViewModel

  @Environment(\.dismiss)
  var dismiss

  init(model: @autoclosure @escaping () -> CollectionShareFlowViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    NavigationStack(path: $model.state) {
      ShareRecipientsSelectionView(isRoot: true, model: model.makeRecipientsViewModel())
        .navigationDestination(for: CollectionShareFlowViewModel.State.self) { state in
          switch state {
          case .sending:
            sendingView
          }
        }
    }
    .alert(model.errorMessage, isPresented: $model.showError) {}
    .animation(.easeInOut, value: model.state)
  }

  var sendingView: some View {
    SendingShareView(hasSucceed: $model.hasSucceed)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if model.hasSucceed {
            Button(CoreLocalization.L10n.Core.kwButtonClose) {
              dismiss()
            }
          }
        }
      }
  }
}
