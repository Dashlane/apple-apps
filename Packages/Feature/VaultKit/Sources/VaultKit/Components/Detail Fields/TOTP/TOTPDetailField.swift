import Combine
import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import TOTPGenerator
import UIComponents
import UIDelight

public struct TOTPDetailField: View {
  public enum Action: Identifiable {
    case copy((_ value: String, _ fieldType: DetailFieldType) -> Void)

    public var id: String {
      switch self {
      case .copy:
        return "copy"
      }
    }
  }

  public let title: String = L10n.Core.credentialDetailViewOtpFieldLabel
  @Binding
  var otpURL: URL?

  @Binding
  var code: String

  @Binding
  var formattedCode: String

  @Binding
  var progress: CGFloat

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
    code: Binding<String>,
    progress: Binding<CGFloat>,
    shouldPresent2FASetupFlow: Binding<Bool>,
    actions: [Action] = [],
    didChange: @escaping () -> Void
  ) {
    self._otpURL = otpURL
    self._code = code
    self._progress = progress
    self._shouldPresent2FASetupFlow = shouldPresent2FASetupFlow
    self.actions = actions
    self.didChange = didChange

    self._formattedCode = .init(
      projectedValue: Binding(
        get: {
          return code.wrappedValue.totpFormated()
        }, set: { _ in }))
  }

  @ViewBuilder
  public var body: some View {
    if otpInfo == nil && !Device.isMac {
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
        .foregroundColor(.ds.text.brand.quiet)
      Button(L10n.Core._2faSetupCta) {
        shouldPresent2FASetupFlow = true
      }
      .foregroundColor(.ds.text.neutral.catchy)
      Spacer()
      Image.ds.caretRight.outlined
        .foregroundColor(.ds.text.brand.quiet)
    }
    .labeled(title)
    .padding(.vertical, 5)
  }

  var otpView: some View {
    HStack {
      ZStack {
        DS.TextField(
          title, text: $formattedCode,
          actions: {
            HStack(spacing: 12) {
              ForEach(actions, id: \.id) { action in
                switch action {
                case .copy(let action):
                  DS.FieldAction.CopyContent { action(code, fiberFieldType) }
                }
              }
              otpSubviewView
                .frame(width: 16, height: 16)
                .padding(.trailing, 13)
            }
          }
        )
        .editionDisabled()
        .id(code)
        .transition(
          AnyTransition
            .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
            .combined(with: .opacity)
        )
      }
      .animation(.default, value: code)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .contentShape(Rectangle())
    .actionSheet(isPresented: $isActionSheetPresented, content: actionSheet)
    .confirmationDialog(
      L10n.Core.kwOtpsecretWarningDeletionTitle,
      isPresented: $isDeleteAlertPresented,
      actions: {
        Button(L10n.Core.kwOtpsecretWarningConfirmButton, role: .destructive) { delete() }
      },
      message: {
        Text(L10n.Core.kwOtpsecretWarningDeletionMessage)
      }
    )
  }

  @ViewBuilder
  private var otpSubviewView: some View {
    switch otpInfo?.type {
    case .totp:
      TimeProgressIndicator(progress: $progress)

    case .hotp(let counter):
      HOTPView(model: otpInfo!, code: $code, initialCounter: counter, counter: $counter) {
        guard let url = otpURL else { return }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = components?.queryItems?.filter { $0.name != "counter" }
        items?.append(URLQueryItem(name: "counter", value: String(self.counter)))
        components?.queryItems = items

        if let updatedUrl = components?.url {
          otpURL = updatedUrl
          didChange()
        }
      }
    case nil:
      EmptyView()
    }
  }

  private func actionSheet() -> ActionSheet {
    if Device.isMac {
      return ActionSheet(
        title: Text(title),
        message: nil,
        buttons: [
          .destructive(Text(L10n.Core.kwOtpSecretDelete), action: presentDelete),
          .cancel(),
        ])
    } else {
      return ActionSheet(
        title: Text(title),
        message: nil,
        buttons: [
          .destructive(Text(L10n.Core.kwOtpSecretDelete), action: presentDelete),
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
        otpURL: .constant(URL(string: "_")), code: .constant(""), progress: .constant(0),
        shouldPresent2FASetupFlow: .constant(false)
      ) {}
      .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
      TOTPDetailField(
        otpURL: .constant(URL(string: "")), code: .constant(""), progress: .constant(0),
        shouldPresent2FASetupFlow: .constant(false)
      ) {}
      .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
      TOTPDetailField(
        otpURL: .constant(URL(string: "_")), code: .constant(""), progress: .constant(0),
        shouldPresent2FASetupFlow: .constant(false)
      ) {}
      .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
    }

  }
}
