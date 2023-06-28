#if os(iOS)
import CoreLocalization
import DesignSystem
import SwiftUI

public struct CollectionsSidebarSectionHeader: View {

    @State
    private var showCollectionAddition: Bool = false

    private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory

    public init(collectionNamingViewModelFactory: CollectionNamingViewModel.Factory) {
        self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
    }

    public var body: some View {
        HStack {
            Text(L10n.Core.KWVaultItem.Collections.toolsTitle)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { showCollectionAddition = true }, label: {
                Image.ds.action.add.outlined
                    .resizable()
                    .frame(width: 16, height: 16)
            })
            .padding(.trailing, 4)
        }
        .sheet(isPresented: $showCollectionAddition) {
            CollectionNamingView(viewModel: collectionNamingViewModelFactory.make(mode: .addition)) { _ in
                showCollectionAddition = false
            }
        }
    }
}

struct CollectionsSidebarSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsSidebarSectionHeader(collectionNamingViewModelFactory: .init { _ in .mock(mode: .addition) })
    }
}
#endif
