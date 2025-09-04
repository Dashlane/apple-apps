import Combine
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import SwiftUI
import UIComponents
import UserTrackingFoundation

public struct CollectionNamingView: View {

  public enum Completion {
    case cancel
    case done(VaultCollection)
  }

  @Environment(\.toast)
  var toast

  @StateObject
  var viewModel: CollectionNamingViewModel

  let completion: (Completion) -> Void

  @FocusState
  private var textFieldFocus

  @State
  private var showSpaceSelector: Bool = false

  public init(
    viewModel: @autoclosure @escaping () -> CollectionNamingViewModel,
    completion: @escaping (Completion) -> Void = { _ in }
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.completion = completion
  }

  public var body: some View {
    NavigationView {
      List {
        DS.TextField(
          CoreL10n.KWVaultItem.Collections.Naming.Field.title,
          placeholder: CoreL10n.KWVaultItem.Collections.Naming.Field.placeholder,
          text: $viewModel.collectionName,
          actions: {
            DS.FieldAction.ClearContent(text: $viewModel.collectionName)
          },
          feedback: {
            if viewModel.showNamingError, !viewModel.inProgress {
              FieldTextualFeedback(sameNameErrorMessage)
                .style(.error)
            }
          }
        )
        .submitLabel(.done)
        .focused($textFieldFocus)
        .textInputAutocapitalization(.words)
        .disableAutocorrection(true)
        .onSubmit {
          viewModel.createOrSave(with: toast, completion: completion)
        }
        .onReceive(Just($viewModel.collectionName)) { _ in
          guard viewModel.collectionName.count > VaultCollection.maxNameLength else { return }
          viewModel.collectionName = String(
            viewModel.collectionName.prefix(VaultCollection.maxNameLength))
        }

        if viewModel.availableUserSpaces.count > 1 {
          SpaceSelectorSection(
            selectedUserSpace: viewModel.collectionUserSpace,
            isUserSpaceForced: viewModel.isUserSpaceForced,
            showSpaceSelector: $showSpaceSelector
          )
          .spaceSelectorSectionFeedback(viewModel.collectionUserSpace.feedbackMessage)
        }
      }
      .listStyle(.ds.insetGrouped)
      .navigationBarTitle(viewModel.mode.navigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            viewModel.cancel(completion: completion)
          }
          .foregroundStyle(Color.ds.text.brand.standard)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          if viewModel.canBeCreatedOrSaved {
            Button(viewModel.mode.navigationBarTrailingButtonTitle) {
              viewModel.createOrSave(with: toast, completion: completion)
            }
            .loading(viewModel.inProgress)
            .foregroundStyle(Color.ds.text.brand.standard)
          }
        }
      }
      .navigation(isActive: $showSpaceSelector) {
        spaceSelectorList
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
          self.textFieldFocus = true
        }
      }
      .reportPageAppearance(viewModel.mode.page)
    }
  }

  private var spaceSelectorList: some View {
    SelectionListView(
      selection: Binding(
        get: { viewModel.collectionUserSpace },
        set: { space in viewModel.collectionUserSpace = space }
      ),
      items: viewModel.availableUserSpaces
    )
    .navigationBarTitle(CoreL10n.KWAuthentifiantIOS.spaceId)
    .navigationBarTitleDisplayMode(.inline)
    .scrollContentBackground(.hidden)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  private var sameNameErrorMessage: String {
    if viewModel.availableUserSpaces.count > 1 {
      return CoreL10n.KWVaultItem.Collections.Naming.SameNameInSpace.message
    } else {
      return CoreL10n.KWVaultItem.Collections.Naming.SameName.message
    }
  }
}

extension CollectionNamingViewModel.Mode {
  fileprivate var navigationTitle: String {
    switch self {
    case .addition:
      return CoreL10n.KWVaultItem.Collections.Naming.Addition.title
    case .edition:
      return ""
    }
  }

  fileprivate var navigationBarTrailingButtonTitle: String {
    switch self {
    case .addition:
      return CoreL10n.KWVaultItem.Collections.create
    case .edition:
      return CoreL10n.kwSave
    }
  }

  fileprivate var page: Page {
    switch self {
    case .addition:
      return .collectionCreate
    case .edition:
      return .collectionEdit
    }
  }
}

extension UserSpace {
  fileprivate var feedbackMessage: String {
    switch self {
    case .personal, .both:
      return CoreL10n.KWVaultItem.Collections.Naming.ForcedPersonalSpace.message
    case .team:
      return CoreL10n.KWVaultItem.Collections.Naming.ForcedSpace.message(teamName)
    }
  }
}

struct CollectionNamingView_Previews: PreviewProvider {
  static var previews: some View {
    CollectionNamingView(viewModel: .mock(mode: .addition))
    CollectionNamingView(
      viewModel: .mock(mode: .edition(.init(collection: PersonalDataMock.Collections.business))))
  }
}
