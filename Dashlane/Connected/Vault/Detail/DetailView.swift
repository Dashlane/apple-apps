import Foundation
import SwiftUI
import VaultKit

struct DetailView: View, SessionServicesInjecting {

    private let itemDetailViewType: ItemDetailViewType
    private let detailViewFactory: DetailViewFactory
    private let dismiss: DetailContainerViewSpecificAction?

    init(
        itemDetailViewType: ItemDetailViewType,
        dismiss: DetailContainerViewSpecificAction? = nil,
        detailViewFactory: DetailViewFactory.Factory
    ) {
        self.itemDetailViewType = itemDetailViewType
        self.dismiss = dismiss
        self.detailViewFactory = detailViewFactory.make()
    }

    var body: some View {
        detailViewFactory.view(for: itemDetailViewType)
            .detailContainerViewSpecificDismiss(dismiss)
    }
}

extension DetailView {
    static func mock(item: VaultItem) -> DetailView {
        .init(itemDetailViewType: .viewing(item),
              detailViewFactory: .init { .mock() })
    }
}
