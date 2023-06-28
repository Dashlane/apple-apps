import SwiftUI
import DesignSystem
import CoreSharing
import VaultKit
import CoreLocalization
import DashTypes
import SwiftTreats
import UIComponents
import UIDelight

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
            SharingMagicRecipientField(text: $model.search)
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

            list

            if isReadyToShare {
                FinalizeSharePeninsula(permission: $model.configuration.permission) {
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
                Button(CoreLocalization.L10n.Core.cancel) {
                    dismiss()
                }
            } else {
                BackButton(color: .accentColor) {
                    dismiss()
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
                        if !model.configuration.isEmpty && (isTextFieldFocused || !model.search.isEmpty) {
                Button(CoreLocalization.L10n.Core.next  + "(\(model.configuration.count))") {
                    model.search = ""
                    isTextFieldFocused = false
                }
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
                    SelectionRow(isSelected: isSelected) {
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
                        SelectionRow(isSelected: isSelected) {
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
            .dismissKeyboardOnDrag()
        }
        .listStyle(.plain)
        .overlay(emptyView)
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
                .foregroundColor(.ds.text.inverse.quiet.opacity(0.5))
                .padding(.horizontal, 40)
        }
    }

    func emailRecipientRow(for recipient: EmailRecipient) -> some View {
        SharingToolRecipientRow(title: recipient.title, subtitle: recipient.subtitle) {
            if let image = recipient.image {
                image.contactsIconStyle(isLarge: false)
            } else {
                GravatarIconView(model: model.gravatarIconViewModelFactory.make(email: recipient.email), backgroundColor: recipient.origin.avatarBackgroundColor)
            }
        }
    }

    func groupRow(for group: SharingItemsUserGroup) -> some View {
        SharingToolRecipientRow(title: group.name, usersCount: group.users.count) {
            UserGroupIcon()
        }
    }
}

struct ShareRecipientsSelectionView_Previews: PreviewProvider {
    static let sharingService = SharingServiceMock(pendingUserGroups: [],
                                                   pendingItemGroups: [],
                                                   sharingUserGroups: [SharingItemsUserGroup(id: "group", name: "A simple group", isMember: true, items: [.mock(id: "1"), .mock(id: "2")], users: [.mock(), .mock(), .mock()])
                                                                      ],
                                                   sharingUsers: [SharingItemsUser(id: "_", items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")]),
                                                                  SharingItemsUser(id: UUID().uuidString, items: [.mock(id: "3")])],
                                                   pendingItems: [:])
    static var previews: some View {
        NavigationView {
            ShareRecipientsSelectionView(isRoot: true, model: .mock(sharingService: sharingService))
        }
        .previewDisplayName("Existing recipients & Root")

        NavigationView {
            ShareRecipientsSelectionView(isRoot: false, model: .mock(sharingService: SharingServiceMock()))
        }
        .previewDisplayName("Empty & Not Root")
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

fileprivate extension EmailRecipient.Origin {
    var avatarBackgroundColor: Color? {
        switch self {
        case .searchField:
            return Color.ds.container.expressive.positive.catchy.idle
        case .sharing, .systemContact:
            return nil
        }
    }
}
