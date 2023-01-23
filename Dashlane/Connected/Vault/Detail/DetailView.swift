import Foundation
import SwiftUI

struct DetailView: View, SessionServicesInjecting {

    private let itemDetailViewType: ItemDetailViewType
    private let detailViewFactory: DetailViewFactory
    private let dismiss: DetailContainerViewSpecificAction?

    init(
        itemDetailViewType: ItemDetailViewType,
        dismiss: DetailContainerViewSpecificAction? = nil,
        sessionServices: SessionServicesContainer
    ) {
        self.itemDetailViewType = itemDetailViewType
        self.dismiss = dismiss
        self.detailViewFactory = DetailViewFactory(sessionServices: sessionServices)
    }

    var body: some View {
        detailViewFactory.view(for: itemDetailViewType)
            .detailContainerViewSpecificDismiss(dismiss)
    }
}
