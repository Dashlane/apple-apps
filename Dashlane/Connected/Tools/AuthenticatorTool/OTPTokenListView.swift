import AuthenticatorKit
import CoreLocalization
import DesignSystem
import IconLibrary
import SwiftTreats
import SwiftUI
import TOTPGenerator
import UIComponents
import UIDelight
import UserTrackingFoundation
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
        .foregroundStyle(Color.ds.text.brand.standard)
      Image(systemName: isListExpanded ? "chevron.up" : "chevron.down")
        .foregroundStyle(Color.ds.text.brand.quiet)
    }
    .frame(height: 50)
    .font(.headline)
  }

  var listView: some View {
    VStack(spacing: isEditing ? 8 : 0) {
      ExpandableForEach(
        viewModel.tokens,
        id: \.id,
        threshold: isEditing || Device.is(.pad, .mac, .vision) ? .max : 5,
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
      RoundedRectangle(cornerRadius: 8).foregroundStyle(
        Color.ds.container.agnostic.neutral.supershy))

  }

  var header: some View {
    Text(L10n.Localizable.otptool2faLoginsHeader)
      .textStyle(.title.section.medium)
      .foregroundStyle(Color.ds.text.neutral.catchy)
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
      }
      .padding()
      .frame(maxWidth: .infinity)
    }
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .alert(item: $itemToDelete) { item in
      deletionAlert(for: item)
    }
    .toolbar(content: {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(
          action: { isEditing.toggle() },
          label: {
            Text(isEditing ? CoreL10n.kwDoneButton : CoreL10n.kwEdit)
              .foregroundStyle(Color.ds.text.neutral.standard)
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
      .buttonStyle(.designSystem(.titleOnly))
      .style(intensity: .supershy)
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
      toast(CoreL10n.kwCopied, image: .ds.action.copy.outlined)
      #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
      #endif
    case let .delete(token):
      self.itemToDelete = token
    }
  }
}

struct OTPTokenListView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      NavigationStack {
        OTPTokenListView(viewModel: .mock, expandedToken: .constant(nil))
      }
    }
  }
}
