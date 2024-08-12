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
      CoreLocalization.L10n.Core.attachmentsLimitation(for: model.item).map {
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

    addCollection
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
            .foregroundColor(.ds.text.danger.quiet)
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
      ? L10n.Core.KWVaultItem.Collections.add : L10n.Core.KWVaultItem.Collections.addAnother
  }

  fileprivate var addCollection: some View {
    Button(
      action: { showCollectionAddition = true },
      label: {
        HStack(spacing: horizontalRowSpacing) {
          Image(systemName: "plus.circle.fill")
            .foregroundColor(.ds.text.positive.standard)
          Text(addCollectionTitle)
            .foregroundColor(.ds.text.brand.standard)
        }
      })
  }
}

extension CollectionsSection {
  @ViewBuilder
  fileprivate var viewingCollectionsList: some View {
    if model.itemCollections.isEmpty {
      Button(L10n.Core.KWVaultItem.Collections.add) {
        showCollectionAddition = true
        model.mode = .updating
      }
      .buttonStyle(DetailRowButtonStyle())
    } else {
      TagsList(
        model.itemCollections.map {
          .init(title: $0.name, trailingAccessory: $0.isShared ? .icon(.ds.shared.outlined) : nil)
        }
      )
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

extension CoreLocalization.L10n.Core {
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
