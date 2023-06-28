import SwiftUI
import UIDelight
import DesignSystem

struct SharingToolsFlow: TabFlow {

        let tag: Int = ConnectedCoordinator.Tab.contacts.tabBarIndexValue
    let id: UUID = .init()
    let title: String = L10n.Localizable.tabContactsTitle
    let tabBarImage = NavigationImageSet(image: .ds.users.outlined,
                                         selectedImage: .ds.users.outlined)

    @StateObject
    var viewModel: SharingToolsFlowViewModel

    init(viewModel: @autoclosure @escaping () -> SharingToolsFlowViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .root:
                SharingToolView(model: viewModel.sharingToolViewModelFactory.make())
                    .environment(\.showVaultItem, viewModel.makeShowVaultItemAction())
                    .navigationBarHidden(false)
            case let .credentialDetails(item):
                viewModel.detailViewFactory.make(itemDetailViewType: .viewing(item))
            }
        }
    }
}

 struct SharingToolsFlow_Previews: PreviewProvider {
    static var previews: some View {
        SharingToolsFlow(viewModel: .mock)
    }
 }
