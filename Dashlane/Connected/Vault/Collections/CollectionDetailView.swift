import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UserTrackingFoundation
import VaultKit

struct CollectionDetailView: View {

  public enum Action {
    case selected(VaultItem)
    case share(VaultCollection)
    case changeSharingAccess(VaultCollection)
  }

  @ScaledMetric
  private var sharedIconSize: CGFloat = 12

  @StateObject
  private var viewModel: CollectionDetailViewModel

  @State
  private var showStarterLimitationAlert: Bool = false

  private let action: (Action) -> Void

  @Environment(\.toast)
  var toast

  init(
    viewModel: @autoclosure @escaping () -> CollectionDetailViewModel,
    action: @escaping (Action) -> Void = { _ in }
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  var body: some View {
    content
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          HStack {
            Text(viewModel.collection.name)
              .fontWeight(.semibold)
              .foregroundStyle(Color.ds.text.neutral.catchy)
            if let space = viewModel.collectionSpace, viewModel.shouldShowSpace {
              UserSpaceIcon(space: space, size: .small)
                .equatable()
            }
            if viewModel.collection.isShared {
              Image.ds.shared.outlined
                .resizable()
                .frame(width: sharedIconSize, height: sharedIconSize)
                .foregroundStyle(Color.ds.text.neutral.quiet)
            }
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          quickActionsMenu
        }
      }
      .alert(isPresented: $showStarterLimitationAlert) {
        Alert(
          title: Text(CoreL10n.starterLimitationUserSharingUnavailableTitle),
          message: Text(CoreL10n.starterLimitationUserSharingUnavailableDescription),
          dismissButton: .default(Text(CoreL10n.starterLimitationUserSharingUnavailableButton))
        )
      }
      .reportPageAppearance(.collectionDetails)
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.sections.isEmpty {
      emptyState
    } else {
      list
    }
  }

  @ViewBuilder
  private var starterInfobox: some View {
    switch viewModel.starterInfo {
    case .warning:
      DS.Infobox(
        CoreL10n.starterLimitationAdminSharingWarningTitle,
        description: CoreL10n.starterLimitationAdminSharingWarningDescription)
    case .limitReached:
      DS.Infobox(
        CoreL10n.starterLimitationAdminSharingLimitReachedTitle,
        description: CoreL10n.starterLimitationAdminSharingLimitReachedDescription
      )
      .style(mood: .warning)
    case .limitReachedAndEditing:
      DS.Infobox(
        CoreL10n.starterLimitationAdminSharingLimitReachedTitle,
        description: CoreL10n.starterLimitationAdminSharingLimitReachedEditingDescription
      )
      .style(mood: .warning)
    case .businessTrialWarning:
      DS.Infobox(
        CoreL10n.starterLimitationBusinessAdminTrialSharingWarningTitle,
        description: CoreL10n.starterLimitationBusinessAdminTrialSharingWarningDescription)
    case .none:
      EmptyView()
    }
  }

  private var list: some View {
    List {
      Section {
        starterInfobox
          .listRowInsets(EdgeInsets())
      }

      ForEach(viewModel.sections) { section in
        Section(section.title) {
          ForEach(section.items, id: \.id) { item in
            ActionableVaultItemRow(
              model: viewModel.makeRowViewModel(item),
              select: { action(.selected(item)) }
            )
            .vaultItemRowCollectionActions(
              [.removeFromThisCollection(.init { viewModel.remove(item, with: toast) })]
            )
            .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
          }
        }
      }
    }
    .listStyle(.ds.insetGrouped)
  }

  private var emptyState: some View {
    VStack {
      starterInfobox
        .padding(20)

      VStack {
        Image.ds.folder.outlined
          .resizable()
          .frame(width: 96, height: 96)
          .foregroundStyle(Color.ds.text.neutral.quiet)

        Text(CoreL10n.KWVaultItem.Collections.Detail.EmptyState.message)
          .font(.body)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal, 24)
      .frame(maxHeight: .infinity)
    }
  }
}

extension CollectionDetailView {
  fileprivate var quickActionsMenu: some View {
    CollectionQuickActionsMenuView(
      viewModel: viewModel.makeQuickActionsMenuViewModel(),
      action: handleQuickActions
    )
  }

  private func handleQuickActions(_ action: CollectionQuickActionsMenuView.Action) {
    switch action {
    case .share(let collection):
      guard !viewModel.isSharingLimitedByStartedPlan else {
        showStarterLimitationAlert = true
        return
      }
      self.action(.share(collection))
    case .changeSharingAccess(let collection):
      self.action(.changeSharingAccess(collection))
    }
  }
}

extension CollectionDetailViewModel.Section: Identifiable {
  var id: String { title }

  var title: String {
    switch type {
    case .credentials:
      return CoreL10n.mainMenuLoginsAndPasswords
    case .secureNotes:
      return CoreL10n.mainMenuNotes
    case .secrets:
      return CoreL10n.mainMenuSecrets
    case .others:
      assertionFailure("Add another section if a new type of item is supporting collections")
      return ""
    }
  }
}

#Preview("Empty State") {
  NavigationStack {
    CollectionDetailView(
      viewModel: CollectionDetailViewModel.mock(
        for: VaultCollection(
          collection: PrivateCollection(
            id: .temporary,
            name: "Banking",
            creationDatetime: .now,
            spaceId: nil,
            items: []
          )
        )
      )
    ) { _ in
    }
  }
}
