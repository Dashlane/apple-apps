import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight

struct CollectionRow: View {

  @ObservedObject
  var viewModel: CollectionRowViewModel

  @ScaledMetric
  private var sharedIconSize: CGFloat = 12

  var body: some View {
    HStack(spacing: 16) {
      information
      Image.ds.caretRight.outlined
        .resizable()
        .frame(width: 20, height: 20, alignment: .trailing)
        .foregroundColor(.ds.text.neutral.quiet)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 4)
  }

  private var information: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 6) {
        Text(viewModel.collection.name)
          .font(.body.weight(.medium))
          .foregroundColor(.ds.text.neutral.catchy)
          .lineLimit(1)

        if viewModel.shouldShowSpace, let space = viewModel.space {
          UserSpaceIcon(space: space, size: .small)
            .equatable()
        }

        if viewModel.collection.isShared {
          Image.ds.shared.outlined
            .resizable()
            .frame(width: sharedIconSize, height: sharedIconSize)
            .foregroundColor(.ds.text.neutral.quiet)
        }
      }
      .animation(.default, value: viewModel.space)
      .frame(maxWidth: .infinity, alignment: .leading)

      itemsCount
    }
  }

  @ViewBuilder
  private var itemsCount: some View {
    let count = viewModel.collection.itemIds.count
    Text(
      count > 1
        ? L10n.Core.KWVaultItem.Collections.ItemsCount.plural(count)
        : L10n.Core.KWVaultItem.Collections.ItemsCount.singular(count)
    )
    .font(.footnote)
    .foregroundColor(.ds.text.neutral.quiet)
    .lineLimit(1)
  }
}

struct CollectionRow_Previews: PreviewProvider {
  static var previews: some View {
    CollectionRow(
      viewModel: .mock(collection: .init(collection: PersonalDataMock.Collections.business)))
  }
}
