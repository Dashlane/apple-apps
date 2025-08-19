import CoreFeature
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct CollectionsSection<Item: VaultItem & Equatable>: View {

  @StateObject
  private var model: CollectionsSectionModel<Item>

  @Binding
  private var showCollectionAddition: Bool

  @ScaledMetric
  private var verticalRowSpacing: CGFloat = 8

  @ScaledMetric
  private var horizontalRowSpacing: CGFloat = 16

  public init(
    model: @autoclosure @escaping () -> CollectionsSectionModel<Item>,
    showCollectionAddition: Binding<Bool>
  ) {
    self._model = .init(wrappedValue: model())
    self._showCollectionAddition = showCollectionAddition
  }

  public var body: some View {
    if model.item.hasAttachments {
      CoreL10n.attachmentsLimitation(for: model.item).map {
        Text($0)
          .textStyle(.body.reduced.regular)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .padding(.vertical, 2)
      }
    } else if model.mode.isEditing {
      editingCollectionsList
    } else {
      viewingCollectionsList
    }
  }
}

extension CollectionsSection {
  @ViewBuilder
  fileprivate var editingCollectionsList: some View {
    ForEach(model.itemCollections) { collection in
      collectionRow(collection)
    }

    if !model.service.isFrozen {
      addCollection
    }
  }

  fileprivate func collectionRow(_ collection: VaultCollection) -> some View {
    HStack(spacing: horizontalRowSpacing) {
      Button(
        action: {
          withAnimation(.easeInOut) {
            model.removeItem(from: collection)
          }
        },
        label: {
          Image(systemName: "minus.circle.fill")
            .foregroundStyle(Color.ds.text.danger.quiet)
        }
      )
      .buttonStyle(.plain)
      .disabled(collection.isShared)

      Tag(
        collection.name, trailingAccessory: collection.isShared ? .icon(.ds.shared.outlined) : nil)
    }
  }

  fileprivate var addCollectionTitle: String {
    model.itemCollections.isEmpty
      ? CoreL10n.KWVaultItem.Collections.add : CoreL10n.KWVaultItem.Collections.addAnother
  }

  fileprivate var addCollection: some View {
    Button(
      action: { showCollectionAddition = true },
      label: {
        HStack(spacing: horizontalRowSpacing) {
          Image(systemName: "plus.circle.fill")
            .foregroundStyle(Color.ds.text.positive.standard)
          Text(addCollectionTitle)
            .foregroundStyle(Color.ds.text.brand.standard)
        }
      })
  }
}

extension CollectionsSection {
  @ViewBuilder
  fileprivate var viewingCollectionsList: some View {
    if model.itemCollections.isEmpty {
      Button(CoreL10n.KWVaultItem.Collections.add) {
        showCollectionAddition = true
        model.mode = .updating
      }
      .buttonStyle(DetailRowButtonStyle())
    } else {
      VWaterfallLayout(spacing: 12) {
        ForEach(model.itemCollections) { collection in
          Tag(
            collection.name,
            trailingAccessory: collection.isShared ? .icon(.ds.shared.outlined) : nil)
        }
      }
      .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
  }
}

struct CollectionsSection_Previews: PreviewProvider {
  static var previews: some View {
    CollectionsSection(
      model: .mock(service: .mock(item: PersonalDataMock.Credentials.adobe, mode: .viewing)),
      showCollectionAddition: .constant(false)
    )
    CollectionsSection(
      model: .mock(service: .mock(item: PersonalDataMock.Credentials.adobe, mode: .updating)),
      showCollectionAddition: .constant(false)
    )
  }
}

extension CoreL10n {
  fileprivate static func attachmentsLimitation(for item: VaultItem) -> String? {
    return switch item.enumerated {
    case .credential:
      Self.KWVaultItem.Collections.AttachmentsLimitation.Message.credential
    case .secureNote:
      Self.KWVaultItem.Collections.AttachmentsLimitation.Message.secureNote
    default:
      nil
    }
  }
}
