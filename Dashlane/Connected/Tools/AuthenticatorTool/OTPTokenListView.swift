import AuthenticatorKit
import CoreLocalization
import CoreUserTracking
import DesignSystem
import IconLibrary
import SwiftUI
import TOTPGenerator
import UIComponents
import UIDelight
import VaultKit

struct OTPTokenListView: View {

  @StateObject
  private var viewModel: OTPTokenListViewModel

  @State
  private var isEditing = false

  @Binding
  var expandedToken: OTPInfo?

  @State
  private var isListExpanded: Bool = false

  @State
  var itemToDelete: OTPInfo?

  init(
    viewModel: @autoclosure @escaping () -> OTPTokenListViewModel,
    expandedToken: Binding<OTPInfo?>
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self._expandedToken = expandedToken
  }

  @Environment(\.toast)
  var toast

  var expansionLabel: some View {
    HStack(spacing: 3) {
      Text(isListExpanded ? L10n.Localizable.otpToolSeeLess : L10n.Localizable.otpToolSeeAll)
        .foregroundColor(.ds.text.brand.standard)
      Image(systemName: isListExpanded ? "chevron.up" : "chevron.down")
        .foregroundColor(.ds.text.brand.quiet)
    }
    .frame(height: 50)
    .font(.headline)
  }

  var listView: some View {
    VStack(spacing: isEditing ? 8 : 0) {
      ExpandableForEach(
        viewModel.tokens,
        id: \.id,
        threshold: isEditing ? .max : 5,
        expanded: $isListExpanded,
        label: { expansionLabel },
        content: { token in
          if token != viewModel.tokens.first, !isEditing {
            Divider().padding(.leading, 12)
          }
          rowView(for: token)
            .cornerRadius(isEditing ? 8 : 0)
        })
    }.background(
      RoundedRectangle(cornerRadius: 8).foregroundColor(.ds.container.agnostic.neutral.supershy))

  }

  var header: some View {
    Text(L10n.Localizable.otptool2faLoginsHeader)
      .font(.custom(GTWalsheimPro.regular.name, size: 20, relativeTo: .largeTitle).weight(.medium))
      .frame(alignment: .leading)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 16) {
          header
          listView
        }

        if !isListExpanded && !isEditing {
          actionButtons
        }
      }.padding()
    }
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .alert(item: $itemToDelete) { item in
      deletionAlert(for: item)
    }
    .toolbar(content: {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(
          action: { isEditing.toggle() },
          label: {
            Text(
              isEditing
                ? CoreLocalization.L10n.Core.kwDoneButton : CoreLocalization.L10n.Core.kwEdit
            )
            .foregroundColor(.ds.text.neutral.standard)
          })
      }
    })
    .navigationTitle(L10n.Localizable.otpToolName)
    .navigationBarTitleDisplayMode(.inline)
    .animation(.easeOut, value: expandedToken)
    .animation(.easeInOut, value: isListExpanded)
    .animation(.easeInOut, value: isEditing)
    .onAppear {
      expandedToken = viewModel.tokens.first
    }
  }

  var actionButtons: some View {
    VStack {
      Button(L10n.Localizable.otpToolSetupCta) {
        viewModel.startSetupOTPFlow()
      }
      .buttonStyle(.designSystem(.titleOnly))

      Button(L10n.Localizable.otpToolExploreAuthenticator) {
        viewModel.startExplorer()
      }
      .buttonStyle(BorderlessActionButtonStyle())
      .foregroundColor(.ds.text.neutral.standard)
    }
  }

  func rowView(for token: OTPInfo) -> some View {
    TokenRowView(
      model: viewModel.makeTokenRowViewModel(for: token),
      rowMode: rowMode(for: token),
      expandCollapseAction: { toggle(token) },
      performTrailingAction: handleRowTrailingAction
    )
    .frame(minHeight: 60)
    .background(
      Color.ds.background.default
        .onTapGesture {
          toggle(token)
        }
        .fiberAccessibilityHidden(true)
    )
    .fiberAccessibilityAction {
      toggle(token)
    }
  }

  private func toggle(_ token: OTPInfo) {
    if expandedToken == token {
      expandedToken = nil
    } else {
      expandedToken = token
    }
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

  func deletionAlert(for item: OTPInfo) -> Alert {
    Alert(
      title: Text(L10n.Localizable.otptoolDeletionAlertTitle),
      message: Text(
        L10n.Localizable.otptollItemDeletionAlertTitle(item.configuration.issuerOrTitle)),
      primaryButton: .destructive(
        Text(L10n.Localizable.otptollItemDeletionAlertYes), action: { viewModel.delete(item: item) }
      ),
      secondaryButton: .cancel())
  }

  func handleRowTrailingAction(_ action: TokenRowAction) {
    switch action {
    case let .copy(code, otpInfo):
      viewModel.copy(code, for: otpInfo)
      toast(CoreLocalization.L10n.Core.kwCopied, image: .ds.action.copy.outlined)
      UINotificationFeedbackGenerator().notificationOccurred(.success)
    case let .delete(token):
      self.itemToDelete = token
    }
  }
}

struct OTPTokenListView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      OTPTokenListView(viewModel: .mock, expandedToken: .constant(nil))
    }
  }
}
