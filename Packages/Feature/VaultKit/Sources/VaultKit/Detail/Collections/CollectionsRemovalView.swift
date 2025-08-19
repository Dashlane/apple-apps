import CoreFeature
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

public struct CollectionsRemovalView: View {

  public enum Completion {
    case done([VaultCollection])
    case cancel
  }

  @State
  var collections: [VaultCollection]

  @State
  private var collectionsRemoved: [VaultCollection] = []

  @State
  private var showCancelConfirmationDialog: Bool = false

  let completion: (Completion) -> Void

  public init(
    collections: [VaultCollection],
    completion: @escaping (Completion) -> Void
  ) {
    self.collections = collections.sortedByName()
    self.completion = completion
  }

  public var body: some View {
    NavigationView {
      content
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(CoreL10n.cancel) {
              if collectionsRemoved.isEmpty {
                completion(.cancel)
              } else {
                showCancelConfirmationDialog = true
              }
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            if !collectionsRemoved.isEmpty {
              Button(CoreL10n.kwSave) {
                completion(.done(collectionsRemoved))
              }
            }
          }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(CoreL10n.KWVaultItem.Collections.Removal.title)
        .confirmationDialog(
          CoreL10n.KWVaultItem.UnsavedChanges.title,
          isPresented: $showCancelConfirmationDialog,
          titleVisibility: .visible,
          actions: {
            Button(CoreL10n.KWVaultItem.UnsavedChanges.leave, role: .destructive) {
              completion(.cancel)
            }
            Button(CoreL10n.KWVaultItem.UnsavedChanges.keepEditing, role: .cancel) {}
          },
          message: {
            Text(CoreL10n.KWVaultItem.UnsavedChanges.message)
          }
        )
    }
  }

  @ViewBuilder
  private var content: some View {
    if collections.isEmpty {
      emptyState
    } else {
      list
    }
  }

  private var emptyState: some View {
    VStack {
      Image.ds.folder.outlined
        .resizable()
        .frame(width: 96, height: 96)
        .foregroundStyle(Color.ds.text.neutral.quiet)

      Text(CoreL10n.KWVaultItem.Collections.Removal.EmptyState.message)
        .font(.body)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 24)
  }

  private var list: some View {
    List(collections) { collection in
      row(for: collection)
    }
    .listStyle(.ds.insetGrouped)
  }

  private func row(for collection: VaultCollection) -> some View {
    HStack(spacing: 16) {
      Button(
        action: {
          withAnimation(.easeInOut) {
            collections.removeAll(where: { collection.id == $0.id })
            collectionsRemoved.append(collection)
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
}

struct CollectionsRemovalView_Previews: PreviewProvider {
  static var previews: some View {
    CollectionsRemovalView(
      collections: [PersonalDataMock.Collections.business].map(VaultCollection.init(collection:))
    ) { _ in }
  }
}
