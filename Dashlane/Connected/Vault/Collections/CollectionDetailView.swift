import CoreLocalization
import CorePersonalData
import CoreUserTracking
import DesignSystem
import SwiftUI
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
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          HStack {
            Text(viewModel.collection.name)
              .fontWeight(.semibold)
            if let space = viewModel.collectionSpace, viewModel.shouldShowSpace {
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
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          quickActionsMenu
        }
      }
      .alert(isPresented: $showStarterLimitationAlert) {
        Alert(
          title: Text(CoreLocalization.L10n.Core.starterLimitationUserSharingUnavailableTitle),
          message: Text(
            CoreLocalization.L10n.Core.starterLimitationUserSharingUnavailableDescription),
          dismissButton: .default(
            Text(CoreLocalization.L10n.Core.starterLimitationUserSharingUnavailableButton))
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
        CoreLocalization.L10n.Core.starterLimitationAdminSharingWarningTitle,
        description: CoreLocalization.L10n.Core.starterLimitationAdminSharingWarningDescription)
    case .limitReached:
      DS.Infobox(
        CoreLocalization.L10n.Core.starterLimitationAdminSharingLimitReachedTitle,
        description: CoreLocalization.L10n.Core.starterLimitationAdminSharingLimitReachedDescription
      )
      .style(mood: .warning)
    case .limitReachedAndEditing:
      DS.Infobox(
        CoreLocalization.L10n.Core.starterLimitationAdminSharingLimitReachedTitle,
        description: CoreLocalization.L10n.Core
          .starterLimitationAdminSharingLimitReachedEditingDescription
      )
      .style(mood: .warning)
    case .businessTrialWarning:
      DS.Infobox(
        CoreLocalization.L10n.Core.starterLimitationBusinessAdminTrialSharingWarningTitle,
        description: CoreLocalization.L10n.Core
          .starterLimitationBusinessAdminTrialSharingWarningDescription)
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
    .scrollContentBackground(.hidden)
  }

  private var emptyState: some View {
    VStack {
      starterInfobox
        .padding(20)

      VStack {
        Image.ds.folder.outlined
          .resizable()
          .frame(width: 96, height: 96)
          .foregroundColor(.ds.text.neutral.quiet)

        Text(CoreLocalization.L10n.Core.KWVaultItem.Collections.Detail.EmptyState.message)
          .font(.body)
          .foregroundColor(.ds.text.neutral.quiet)
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
      return CoreLocalization.L10n.Core.mainMenuLoginsAndPasswords
    case .secureNotes:
      return CoreLocalization.L10n.Core.mainMenuNotes
    case .secrets:
      return CoreLocalization.L10n.Core.mainMenuSecrets
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
