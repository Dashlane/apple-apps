import CoreLocalization
import DesignSystem
import SwiftUI

public struct CollectionsSidebarSectionHeader: View {

  @Binding
  private var showCollectionAddition: Bool

  private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory

  public init(
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    showCollectionAddition: Binding<Bool>
  ) {
    self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
    self._showCollectionAddition = showCollectionAddition
  }

  public var body: some View {
    HStack {
      Text(CoreL10n.KWVaultItem.Collections.toolsTitle)
        .frame(maxWidth: .infinity, alignment: .leading)

      Button(
        action: { showCollectionAddition = true },
        label: {
          Image.ds.action.add.outlined
            .resizable()
            .frame(width: 16, height: 16)
        })
    }
    .padding(.trailing, -12)
  }
}

struct CollectionsSidebarSectionHeader_Previews: PreviewProvider {
  static var previews: some View {
    CollectionsSidebarSectionHeader(
      collectionNamingViewModelFactory: .init { _ in .mock(mode: .addition) },
      showCollectionAddition: .constant(false)
    )
  }
}
