import CorePremium
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct PurchaseView<Content: View>: View {

  enum Action {
    case cancel
  }

  @StateObject
  var model: PurchaseViewModel

  let action: (Action) -> Void
  let content: ([PurchasePlan.Kind: PlanTier]) -> Content

  init(
    model: @escaping @autoclosure () -> PurchaseViewModel, action: @escaping (Action) -> Void,
    @ViewBuilder content: @escaping ([PurchasePlan.Kind: PlanTier]) -> Content
  ) {
    self._model = .init(wrappedValue: model())
    self.action = action
    self.content = content
  }

  var body: some View {
    Group {
      switch model.state {
      case .loading:
        ProgressView()
          .controlSize(.large)
          .progressViewStyle(.indeterminate)
      case .empty:
        PurchaseEmptyView(cancel: { action(.cancel) })
      case let .fetched(groups):
        content(groups)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }
}

#Preview("Loading State") {
  PurchaseView(
    model: PurchaseViewModel(initialState: .loading), action: { _ in },
    content: { _ in
      Text("Hello")
    })
}

#Preview("Empty State") {
  PurchaseView(
    model: PurchaseViewModel(initialState: .empty), action: { _ in },
    content: { _ in
      Text("Hello")
    })
}

#Preview("Fetched State") {
  PurchaseView(
    model: PurchaseViewModel(initialState: .fetched([:])), action: { _ in },
    content: { _ in
      Text("Hello")
    })
}
