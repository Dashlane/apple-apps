#if os(iOS)
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct CollectionsSection<Item: VaultItem & Equatable>: View {

    @ObservedObject
    private var model: CollectionsSectionModel<Item>

    @Binding
    private var showCollectionAddition: Bool

    @ScaledMetric
    private var verticalRowSpacing: CGFloat = 8

    @ScaledMetric
    private var horizontalRowSpacing: CGFloat = 16

    public init(model: CollectionsSectionModel<Item>, showCollectionAddition: Binding<Bool>) {
        self.model = model
        self._showCollectionAddition = showCollectionAddition
    }

    public var body: some View {
        if model.mode.isEditing {
            editingCollectionsList
        } else {
            viewingCollectionsList
        }
    }
}

private extension CollectionsSection {
    var singleSpaceSectionTitle: String {
        model.itemCollections.count > 1 ? L10n.Core.KWVaultItem.Collections.Title.plural : L10n.Core.KWVaultItem.Collections.Title.singular
    }

    var personalSectionTitle: String {
        if model.itemCollections.count > 1 {
            return L10n.Core.KWVaultItem.Collections.Title.PersonalSpace.plural
        } else {
            return L10n.Core.KWVaultItem.Collections.Title.PersonalSpace.singular
        }
    }

    var businessSectionTitle: String {
        if model.itemCollections.count > 1 {
            return L10n.Core.KWVaultItem.Collections.Title.BusinessSpace.plural(model.selectedUserSpace.teamName)
        } else {
            return L10n.Core.KWVaultItem.Collections.Title.BusinessSpace.singular(model.selectedUserSpace.teamName)
        }
    }

    var sectionTitle: String {
        if model.availableUserSpaces.count > 1 {
            switch model.selectedUserSpace {
            case .personal, .both:
                return personalSectionTitle
            case .business:
                return businessSectionTitle
            }
        } else {
            return singleSpaceSectionTitle
        }
    }
}

private extension CollectionsSection {
    var editingCollectionsList: some View {
        Section(sectionTitle) {
            ForEach(model.itemCollections) { collection in
                collectionRow(collection)
            }

            addCollection
        }
    }

    func collectionRow(_ collection: VaultCollection) -> some View {
        HStack(spacing: horizontalRowSpacing) {
            Button(action: {
                withAnimation(.easeInOut) {
                    model.removeItem(from: collection)
                }
            }, label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.ds.text.danger.quiet)
            })
            .buttonStyle(.plain)

            Tag(collection.name)
        }
    }

    var addCollectionTitle: String {
        model.itemCollections.isEmpty ? L10n.Core.KWVaultItem.Collections.add : L10n.Core.KWVaultItem.Collections.addAnother
    }

    var addCollection: some View {
        Button(action: { showCollectionAddition = true }, label: {
            HStack(spacing: horizontalRowSpacing) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.ds.text.positive.standard)
                Text(addCollectionTitle)
                    .foregroundColor(.ds.text.brand.standard)
            }
        })
    }
}

private extension CollectionsSection {
    var viewingCollectionsList: some View {
        Section(sectionTitle) {
            if model.itemCollections.isEmpty {
                Button(L10n.Core.KWVaultItem.Collections.add) {
                    showCollectionAddition = true
                    model.mode = .updating
                }
                .buttonStyle(DetailRowButtonStyle())
            } else {
                TagsList(model.itemCollections.map(\.name))
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
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
#endif
