import Foundation
import SwiftUI
import Combine
import DashlaneAppKit
import UIDelight
import AuthenticatorKit
import DesignSystem
import UIComponents

struct TokenListView<Content: View>: View {

    enum NavigationItem {
        case detail(OTPInfo)
        case help
    }

    @StateObject
    var model: TokenListViewModel

    @State
    var itemToDelete: OTPInfo?

    @State
    var inDeletionItem: OTPInfo?

    @Binding
    var expandedToken: OTPInfo?

    var addAction: (_ skipIntro: Bool) -> Void

    @Binding
    var showAnnouncement: Bool

    @State
    private var isEditing = false

    let announcementContent: () -> Content

    @Environment(\.dismiss)
    var dismiss

    init(model: @autoclosure @escaping () -> TokenListViewModel,
         expandedToken: Binding<OTPInfo?>,
         addAction: @escaping (_ skipIntro: Bool) -> Void,
         showAnnouncement: Binding<Bool>,
         @ViewBuilder announcementContent: @escaping () -> Content) {
        self._model = .init(wrappedValue: model())
        _expandedToken = expandedToken
        self.addAction = addAction
        _showAnnouncement = showAnnouncement
        self.announcementContent = announcementContent
    }

    @Environment(\.toast)
    var toast

    @State
    var isScrollOnTop = false

    @State
    var listBottomPadding: CGFloat = 0

    var body: some View {
        StepBasedContentNavigationView(steps: $model.steps) { step in
            switch step {
            case .list:
                Group {
                    if model.tokens.isEmpty && model.favorites.isEmpty {
                        emptyTokensView
                    } else {
                        scrollView
                            .overlay(addNewAccountOverlay, alignment: .bottom)
                            .toolbar(content: { toolbarContent })
                    }
                }
            case let .detail(item):
                TokenDetailView(model: TokenDetailViewModel(token: item, databaseService: model.databaseService, tokenAction: handleRowTrailingAction))
            case .help:
                HelpView(addAction: addAction)
            }
        }
        .navigationTitle(isEditing ? L10n.Localizable.tokensListStartEdit : L10n.Localizable.tokensListNavigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarStyle(.brandedBarStyle)
        .animation(.easeInOut, value: isEditing)
        .animation(.easeInOut, value: model.tokens)
        .animation(.easeInOut, value: model.favorites)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if isEditing {
                Button(L10n.Localizable.tokensListEditionClose) {
                    self.isEditing = false
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if !isEditing {
                Menu {
                    Button {
                        self.isEditing = true
                    } label: {
                        Text(L10n.Localizable.buttonEdit)
                        Image.ds.action.edit.outlined
                    }
                    Button {
                        model.showHelp()
                    } label: {
                        Text(L10n.Localizable.addOtpFlowHelpCta)
                        Image.ds.feedback.help.outlined
                            .foregroundColor(.ds.text.neutral.standard)
                    }
                } label: {
                    Image.ds.action.moreEmphasized.outlined
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.ds.text.neutral.standard)
                }
            }
        }
    }

    var scrollView: some View {
        TrackableScrollView(isOnTop: $isScrollOnTop.animation(.easeInOut)) {
            VStack(spacing: 24) {
                if showAnnouncement && !isEditing {
                    announcementContent()
                        .padding(.top)
                }
                if !model.favorites.isEmpty {
                    favoriteListView
                }
                listView
            }
        }
        .animation(.easeInOut, value: expandedToken)
        .animation(.easeInOut, value: showAnnouncement)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .alert(item: $itemToDelete) { item in
            alert(for: item)
        }.onAppear {
            expandedToken = model.favorites.first ?? model.tokens.first
        }
    }

    var listView: some View {
        list(for: model.tokens, title: L10n.Localizable.listOtherSectionTitle)
            .padding(.bottom, listBottomPadding)
    }

    var favoriteListView: some View {
        list(for: model.favorites, title: L10n.Localizable.listFavoriteSectionTitle)
    }

    @ViewBuilder
    func list(for items: [OTPInfo], title: String) -> some View {
        VStack(spacing: 8) {
            if !model.tokens.isEmpty && !model.favorites.isEmpty {
                section(title: title)
            }
            VStack(spacing: isEditing ? 8 : 0) {
                ForEach(items) { token in
                    if token != items.first, !isEditing {
                        Divider()
                            .padding(.leading, 12)
                    }

                    rowView(for: token)
                        .cornerRadius(isEditing ? 8 : 0)
                }
            }
            .cornerRadius(isEditing ? 0 : 8)
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    func section(title: String) -> some View {
        Text(title)
            .font(.system(size: 13))
            .textCase(.none)
            .foregroundColor(.ds.text.neutral.quiet)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity)
    }

    func rowMode(for token: OTPInfo) -> TokenRowMode {
        if isEditing {
            return .edition
        } else if token.id == expandedToken?.id {
                        return .expanded
        } else {
            return .view
        }
    }

    @ViewBuilder
    func rowView(for token: OTPInfo) -> some View {
        TokenRowView(model: model.makeTokenRowViewModel(for: token),
                     rowMode: rowMode(for: token),
                     performTrailingAction: handleRowTrailingAction)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            if expandedToken == token {
                expandedToken = nil
            } else {
                expandedToken = token
            }
        }
        .background(.ds.container.agnostic.neutral.supershy)
        .deletableRow(
            isEnabled: !isEditing && inDeletionItem == nil || inDeletionItem == token,
            deleteImage: Image.ds.action.delete.outlined,
            isInProgress: { inProgress in
                inDeletionItem = inProgress ? token : nil
            },
            perform: {
                self.itemToDelete = token
            }
        )
    }
}

extension TokenListView {
    func alert(for item: OTPInfo) -> Alert {
        Alert(title: Text(L10n.Localizable.otpDeletionTitle(item.configuration.issuerOrTitle)),
              message: Text(L10n.Localizable.otpDeletionMessage(item.configuration.issuerOrTitle)),
              primaryButton: .destructive(Text(L10n.Localizable.otpDeletionConfirmButton), action: { model.delete(item: item)}),
              secondaryButton: .cancel())
    }

    @ViewBuilder
    var addNewAccountOverlay: some View {
        if !isEditing && isScrollOnTop {
            addNewAccountButton
                .transition(.opacity.combined(with: .offset(x: 0, y: 10)))
        }
    }

    var addNewAccountButton: some View {
        RoundedButton(L10n.Localizable.addOtpFlowAddNewCta, action: { addAction(false) })
            .roundedButtonLayout(.fill)
            .padding(.horizontal)
            .padding(.bottom)
            .onSizeChange {
                self.listBottomPadding = $0.height
            }
            .padding(.top)
            .background(addNewAccountBackground)
    }

    @ViewBuilder
    var addNewAccountBackground: some View {
        let colors = [Color.ds.background.alternate,
                      Color.ds.background.alternate.opacity(0)]
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .init(x: 0.5, y: 0.8), endPoint: .top).edgesIgnoringSafeArea(.bottom)
    }

    func handleRowTrailingAction(_ action: TokenRowAction) {
        switch action {
        case let .copy(code, _):
            UIPasteboard.general.string = code
            toast(L10n.Localizable.copiedCodeToastMessage, image: .ds.action.copy.outlined)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case let .delete(token):
            model.delete(item: token)
        case let .didDelete(token):
            model.didDelete(token)
        case let .update(token):
            model.update(item: token)
        case let .detail(token):
            model.steps.append(.detail(token))
        }
    }

    @ViewBuilder
    var emptyTokensView: some View {
        VStack {
            helpLabel
                .padding(16)
            Spacer()
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .overlay {
            VStack(spacing: 32) {
                Spacer()
                Image.ds.lock.outlined
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.ds.text.oddity.disabled)
                Text(L10n.Localizable.tokenListEmptyMessage)
                    .font(.body)
                    .foregroundColor(.ds.text.neutral.standard)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                Spacer()
                addNewAccountButton
            }
        }
        .onAppear {
                        self.isEditing = false
        }
    }

    var helpLabel: some View {
        Button(action: {
            addAction(true)
        },
               label: {
            HStack {
                Image.ds.feedback.help.outlined
                Text(L10n.Localizable.tokenListHelpLabel)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.body.weight(.medium))
            .foregroundColor(.ds.text.neutral.standard)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(.ds.background.default)
            .cornerRadius(8)
        })
    }
}

struct TokenListView_preview: PreviewProvider {

    static var previews: some View {
        MultiContextPreview {
            NavigationView {
                TokenListView(
                    model: .mock(),
                    expandedToken: .constant(nil),
                    addAction: {_ in},
                    showAnnouncement: .constant(false),
                    announcementContent: {
                        EmptyView()
                    }
                )
            }
        }
    }
}
