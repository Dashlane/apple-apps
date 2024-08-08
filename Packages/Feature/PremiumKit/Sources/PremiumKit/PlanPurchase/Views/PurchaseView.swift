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
        ProgressViewBox()
          .tint(.ds.text.brand.standard)
      case .empty:
        PurchaseEmptyView(cancel: { action(.cancel) })
      case let .fetched(groups):
        content(groups)
      }
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }
}

struct PurchaseView_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      PurchaseView(
        model: PurchaseViewModel(initialState: .loading), action: { _ in },
        content: { _ in
          Text("Hello")
        })
      PurchaseView(
        model: PurchaseViewModel(initialState: .empty), action: { _ in },
        content: { _ in
          Text("Hello")
        })
      PurchaseView(
        model: PurchaseViewModel(initialState: .fetched([:])), action: { _ in },
        content: { _ in
          Text("Hello")
        })
    }
  }
}
