import SwiftUI
import CorePremium
import UIDelight
import UIComponents
import DesignSystem

struct PurchaseView<Content: View>: View {

    enum Action {
        case cancel
    }

    @ObservedObject
    var model: PurchaseViewModel

    let action: (Action) -> Void
    let content: ([PurchasePlan.Kind: PlanTier]) -> Content

    init(model: PurchaseViewModel, action: @escaping (Action) -> Void, @ViewBuilder content: @escaping ([PurchasePlan.Kind: PlanTier]) -> Content) {
        self.model = model
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
            PurchaseView(model: PurchaseViewModel(initialState: .loading), action: { _ in }, content: { _ in
                Text("Hello")
            })
            PurchaseView(model: PurchaseViewModel(initialState: .empty), action: { _ in }, content: { _ in
                Text("Hello")
            })
            PurchaseView(model: PurchaseViewModel(initialState: .fetched([:])), action: { _ in }, content: { _ in
                Text("Hello")
            })
        }
    }
}
