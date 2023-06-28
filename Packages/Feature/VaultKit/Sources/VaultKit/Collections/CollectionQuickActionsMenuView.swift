import CoreLocalization
import CoreFeature
import DesignSystem
import SwiftUI

public struct CollectionQuickActionsMenuView: View {
    
    @FeatureState(.sharingCollectionMilestone1)
    private var isSharingCollectionMilestone1Enabled: Bool

    @StateObject
    var viewModel: CollectionQuickActionsMenuViewModel

    @Environment(\.toast)
    var toast

    @State
    private var showEdit: Bool = false

    @State
    private var showDelete: Bool = false
    
    @State
    private var showSharing: Bool = false

    public init(viewModel: @autoclosure @escaping () -> CollectionQuickActionsMenuViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    public var body: some View {
        Menu {
                        if isSharingCollectionMilestone1Enabled, !viewModel.collection.belongsToSpace(id: "") {
                shareButton
            }
            editButton
            deleteButton
        } label: {
            Image.ds.action.moreEmphasized.outlined
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibility(label: Text(L10n.Core.kwActions))
                .frame(width: 24, height: 40)
                .foregroundColor(.ds.text.brand.standard)
        }
        .toasterOn()
        .onTapGesture {
            viewModel.reportAppearance()
        }
        .sheet(isPresented: $showEdit) {
            #if canImport(UIKit)
            CollectionNamingView(viewModel: viewModel.makeEditableCollectionNamingViewModel()) { completion in
                if case .done(let collection) = completion {
                    viewModel.collection = collection
                }
                showEdit = false
            }
            #endif
        }
        .confirmationDialog(
            L10n.Core.KWVaultItem.Collections.DeleteAlert.title,
            isPresented: $showDelete,
            titleVisibility: .visible,
            actions: {
                Button(L10n.Core.kwDelete, role: .destructive) { viewModel.deleteCollection(with: toast) }
                Button(L10n.Core.cancel, role: .cancel) { }
            },
            message: {
                Text(L10n.Core.KWVaultItem.Collections.DeleteAlert.message)
            }
        )
    }

    private var editButton: some View {
        Button(
            action: {
                showEdit = true
            },
            label: {
                HStack {
                    Text(L10n.Core.kwEdit)
                    Image.ds.action.edit.outlined
                }
            }
        )
    }

    private var deleteButton: some View {
        Button(
            role: .destructive,
            action: {
                viewModel.reportDeletionAppearance()
                showDelete = true
            },
            label: {
                HStack {
                    Text(L10n.Core.kwDelete)
                    Image.ds.action.delete.outlined
                }
            }
        )
    }
    
    private var shareButton: some View {
        Button(
            action: {
                showSharing = true
            },
            label: {
                HStack {
                    Text(L10n.Core.kwShare)
                    Image.ds.action.share.outlined
                }
            }
        )
    }
}

struct CollectionQuickActionsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionQuickActionsMenuView(viewModel: .mock(collection: PersonalDataMock.Collections.business))
    }
}
