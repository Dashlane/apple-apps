import CoreLocalization
import CoreSharing
import CoreTypes
import DesignSystem
import DesignSystemExtra
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct ShareRecipientsSelectionView: View {
  @StateObject
  var model: ShareRecipientsSelectionViewModel

  let isRoot: Bool

  @Environment(\.dismiss)
  var dismiss

  @FocusState
  var isTextFieldFocused

  init(isRoot: Bool, model: @escaping @autoclosure () -> ShareRecipientsSelectionViewModel) {
    self.isRoot = isRoot
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    let isReadyToShare = model.isReadyToShare && !isTextFieldFocused

    VStack(alignment: .leading, spacing: 0) {
      SharingMagicRecipientField(text: $model.search, placeholderText: model.placeholderText)
        .padding(.horizontal)
        .focused($isTextFieldFocused)
        .onSubmit {
          if self.model.isSearchInsertable {
            model.addCurrentSearch()
            isTextFieldFocused = true
          }
        }
        .submitLabel(submitLabel)

      Divider()
        .padding(.horizontal)
        .padding(.top, 10)

      if let infoboxContent = self.model.infoboxContent, !isTextFieldFocused {
        Infobox(infoboxContent.title, description: infoboxContent.text)
          .padding()
      }

      if model.showTeamOnly,
        isTextFieldFocused,
        model.groups.count == 0,
        model.emailRecipients.count == 0
      {
        Text(warningLabel)
          .font(.footnote)
          .foregroundStyle(Color.ds.text.danger.standard)
          .padding()
      }

      list

      if isReadyToShare {
        FinalizeSharePeninsula(
          permission: $model.configuration.permission,
          showPermissionLevelSelector: self.model.showPermissionLevelSelector
        ) {
          model.share()
        }
        .ignoresSafeArea(.keyboard)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .navigationTitle(L10n.Localizable.kwShareItem)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
    .navigationBarBackButtonHidden(true)
    .animation(.spring(), value: isReadyToShare)
    .animation(.easeInOut, value: model.emailRecipients)
    .animation(.easeInOut, value: model.groups)
    .reportPageAppearance(.sharingCreateMember)
  }

  private var warningLabel: String {
    model.configuration.sharingType == .collection
      ? CoreL10n.collectionSharingTeamOnlyWarning : CoreL10n.itemSharingTeamOnlyWarning
  }

  var submitLabel: SubmitLabel {
    if model.isSearchInsertable {
      return .next
    } else if model.isReadyToShare {
      return .done
    } else {
      return .search
    }
  }
}

extension ShareRecipientsSelectionView {
  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      if isRoot {
        Button(
          action: {
            dismiss()
          },
          label: {
            Text(CoreL10n.cancel)
              .foregroundStyle(Color.ds.text.brand.standard)
          })
      } else {
        NativeNavigationBarBackButton {
          dismiss()
        }
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      if !model.configuration.isEmpty && (isTextFieldFocused || !model.search.isEmpty) {
        let a11yLabel =
          model.configuration.count == 1
          ? L10n.Localizable.sharingRecipientSelected(model.configuration.count)
          : L10n.Localizable.sharingRecipientsSelected(model.configuration.count)
        Button(CoreL10n.next + "(\(model.configuration.count))") {
          model.search = ""
          isTextFieldFocused = false
        }
        .accessibilityLabel(a11yLabel)
      }
    }
  }
}

extension ShareRecipientsSelectionView {
  var list: some View {
    ScrollViewReader { _ in
      List {
        ForEach(model.groups) { group in
          let isSelected = model.configuration.groupIds.contains(group.id)
          NativeSelectionRow(isSelected: isSelected) {
            groupRow(for: group)
          }.onTapWithFeedback {
            model.toggle(group)
            resetSearchFieldIfNeeded()
          }
        }

        ForEach(model.emailRecipients) { info in
          let recipient = info.recipient
          let isSelected = model.configuration.userEmails.contains(recipient.email)

          switch info.action {
          case .add:
            AddRecipientRow {
              model.add(recipient)
              resetSearchFieldIfNeeded()
            } label: {
              emailRecipientRow(for: recipient)
            }
            .deleteDisabled(true)
            .style(mood: .neutral, intensity: model.isSearchInsertable ? .catchy : .quiet)

          case let .toggle(isRemovable):
            NativeSelectionRow(isSelected: isSelected) {
              emailRecipientRow(for: recipient)
            }.onTapWithFeedback {
              model.toggle(recipient)
              resetSearchFieldIfNeeded()
            }
            .deleteDisabled(!isRemovable)
          }
        }.onDelete { indexSet in
          model.delete(at: indexSet)
        }
      }
      #if !os(visionOS)
        .scrollDismissesKeyboard(.immediately)
      #endif
    }
    .listStyle(.ds.plain)
    .overlay(emptyView)
    .loading(!model.isLoaded)
  }

  func resetSearchFieldIfNeeded() {
    if model.recipientsCount == 1 {
      model.search = ""
    } else {
      isTextFieldFocused = false
    }
  }

  @ViewBuilder
  var emptyView: some View {
    if model.hasNoRecipients {
      Image.ds.group.outlined
        .resizable()
        .frame(width: 60, height: 60)
        .foregroundStyle(Color.ds.text.inverse.quiet.opacity(0.5))
        .padding(.horizontal, 40)
    }
  }

  func emailRecipientRow(for recipient: EmailRecipient) -> some View {
    SharingToolRecipientRow(
      title: recipient.title,
      subtitle: recipient.subtitle,
      permission: model.configuration.sharingType == .collection
        ? model.configuration.permission : nil
    ) {
      if let image = recipient.image {
        Thumbnail.User.single(image)
      } else {
        GravatarIconView(
          model: model.gravatarIconViewModelFactory.make(email: recipient.email),
          backgroundColor: recipient.origin.avatarBackgroundColor
        )
      }
    }
  }

  func groupRow(for group: SharingEntitiesUserGroup) -> some View {
    SharingToolRecipientRow(
      title: group.name,
      usersCount: group.users.count,
      permission: model.configuration.sharingType == .collection
        ? model.configuration.permission : nil
    ) {
      Thumbnail.User.group
    }
  }
}

struct ShareRecipientsSelectionView_Previews: PreviewProvider {
  static let sharingService = SharingServiceMock(
    pendingUserGroups: [],
    pendingItemGroups: [],
    sharingUserGroups: [
      .init(
        id: "group", name: "A simple group", isMember: true,
        items: [.mock(id: "1"), .mock(id: "2")], users: [.mock(), .mock(), .mock()])
    ],
    sharingUsers: [
      .init(id: "_", items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
      .init(id: UUID().uuidString, items: [.mock(id: "3")]),
    ],
    pendingItems: [:])

  static var searchingViewModel: ShareRecipientsSelectionViewModel {
    let viewModel = ShareRecipientsSelectionViewModel.mock(sharingService: sharingService)
    viewModel.search = "musk"
    viewModel.showTeamOnly = true
    return viewModel
  }

  static var previews: some View {
    NavigationView {
      ShareRecipientsSelectionView(isRoot: true, model: .mock(sharingService: sharingService))
    }
    .previewDisplayName("Existing recipients & Root")

    NavigationView {
      ShareRecipientsSelectionView(
        isRoot: false, model: .mock(sharingService: SharingServiceMock()))
    }
    .previewDisplayName("Empty & Not Root")

    NavigationView {
      ShareRecipientsSelectionView(isRoot: false, model: searchingViewModel)
    }
    .previewDisplayName("Searching")
  }
}

extension ShareRecipientsSelectionViewModel {
  func delete(at indexSet: IndexSet) {
    guard let index = indexSet.first else {
      return
    }

    remove(emailRecipients[index].recipient)
  }
}

extension EmailRecipient.Origin {
  fileprivate var avatarBackgroundColor: Color? {
    switch self {
    case .searchField:
      return Color.ds.container.expressive.positive.catchy.idle
    case .sharing, .systemContact:
      return nil
    }
  }
}
