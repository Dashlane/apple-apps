import Combine
import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import TOTPGenerator
import UIComponents
import UIDelight

public struct TOTPDetailField: View, CopiableDetailField {
  public enum Action: Identifiable {
    case copy((_ value: String, _ fieldType: DetailFieldType) -> Void)

    public var id: String {
      switch self {
      case .copy:
        return "copy"
      }
    }
  }

  public let title: String = CoreL10n.credentialDetailViewOtpFieldLabel
  @Binding
  var otpURL: URL?

  @Binding
  var shouldPresent2FASetupFlow: Bool

  let actions: [Action]

  let didChange: () -> Void

  @State
  var isActionSheetPresented: Bool = false

  @State
  var isDeleteAlertPresented: Bool = false

  @Environment(\.detailMode)
  var detailMode

  @Environment(\.detailFieldType)
  public var fiberFieldType

  public var copiableValue: Binding<String> {
    return .constant(otpInfo?.generate() ?? "")
  }

  var otpInfo: OTPConfiguration? {
    guard let otpURL = otpURL else {
      return nil
    }
    return try? OTPConfiguration(otpURL: otpURL)
  }

  @State
  var counter: UInt64 = 0

  public init(
    otpURL: Binding<URL?>,
    shouldPresent2FASetupFlow: Binding<Bool>,
    actions: [Action] = [],
    didChange: @escaping () -> Void
  ) {
    self._otpURL = otpURL
    self._shouldPresent2FASetupFlow = shouldPresent2FASetupFlow
    self.actions = actions
    self.didChange = didChange
  }

  @ViewBuilder
  public var body: some View {
    if otpInfo == nil && !Device.is(.mac) {
      actionView
    } else if detailMode.isEditing {
      otpView.onTapGesture {
        self.isActionSheetPresented = self.detailMode.isEditing
      }
    } else {
      otpView
    }
  }

  var actionView: some View {
    HStack(alignment: .center, spacing: 2) {
      Image.ds.healthPositive.outlined
        .resizable()
        .frame(width: 23, height: 23)
        .foregroundStyle(Color.ds.text.brand.quiet)
      Button(CoreL10n._2faSetupCta) {
        shouldPresent2FASetupFlow = true
      }
      .foregroundStyle(Color.ds.text.neutral.catchy)
      Spacer()
      Image.ds.caretRight.outlined
        .foregroundStyle(Color.ds.text.brand.quiet)
    }
    .labeled(title)
  }

  @ViewBuilder
  var otpView: some View {
    Group {
      if let otpInfo {
        TOTPView(configuration: otpInfo) { state in
          if detailMode.isEditing {
            DS.TextField(
              title, text: .constant(state.code.totpFormated()),
              actions: {
                otpActionsView(code: state.code, progress: state.progress)
              }
            )
            .fieldEditionDisabled()
            .id(state.code)
            .transition(
              AnyTransition
                .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
                .combined(with: .opacity)
            )
          } else {
            DS.DisplayField(
              title, text: state.code.totpFormated(),
              actions: {
                otpActionsView(code: state.code, progress: state.progress)
              }
            )
            .id(state.code)
            .transition(
              AnyTransition
                .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
                .combined(with: .opacity)
            )
          }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
      } else {
        EmptyView()
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
    .actionSheet(isPresented: $isActionSheetPresented, content: actionSheet)
    .confirmationDialog(
      CoreL10n.kwOtpsecretWarningDeletionTitle,
      isPresented: $isDeleteAlertPresented,
      actions: {
        Button(CoreL10n.kwOtpsecretWarningConfirmButton, role: .destructive) { delete() }
      },
      message: {
        Text(CoreL10n.kwOtpsecretWarningDeletionMessage)
      }
    )
  }

  @ViewBuilder
  private func otpActionsView(code: String, progress: Double) -> some View {
    HStack(spacing: 0) {
      ForEach(actions, id: \.id) { action in
        switch action {
        case .copy(let action):
          DS.FieldAction.CopyContent { action(code, fiberFieldType) }
            .frame(minWidth: 40, minHeight: 40)
        }
      }

      ProgressView(value: progress)
        .progressViewStyle(.countdown)
        .controlSize(.small)
        .animation(.linear(duration: 1), value: progress)
        .frame(minWidth: 40, minHeight: 40)
        .id(code)
    }
  }

  private func actionSheet() -> ActionSheet {
    if Device.is(.mac) {
      return ActionSheet(
        title: Text(title),
        message: nil,
        buttons: [
          .destructive(Text(CoreL10n.kwOtpSecretDelete), action: presentDelete),
          .cancel(),
        ])
    } else {
      return ActionSheet(
        title: Text(title),
        message: nil,
        buttons: [
          .destructive(Text(CoreL10n.kwOtpSecretDelete), action: presentDelete),
          .cancel(),
        ])
    }
  }

  private func presentDelete() {
    self.isDeleteAlertPresented = true
  }

  private func delete() {
    withAnimation(.linear) {
      self.otpURL = nil
    }
  }
}

extension String {
  func totpFormated() -> String {
    var formattedString = self
    let index = formattedString.index(self.startIndex, offsetBy: self.count / 2)
    formattedString.insert(contentsOf: " ", at: index)
    return formattedString
  }
}

struct TOTPDetailField_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TOTPDetailField(
        otpURL: .constant(URL(string: "_")), shouldPresent2FASetupFlow: .constant(false)
      ) {}
      .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
      TOTPDetailField(
        otpURL: .constant(URL(string: "")), shouldPresent2FASetupFlow: .constant(false)
      ) {}
      .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
      TOTPDetailField(
        otpURL: .constant(URL(string: "_")), shouldPresent2FASetupFlow: .constant(false)
      ) {}
      .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
    }

  }
}
