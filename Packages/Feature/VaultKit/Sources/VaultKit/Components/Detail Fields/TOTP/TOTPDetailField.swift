#if os(iOS)
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
        shouldPresent2FASetupFlow: Binding<Bool>,
        actions: [Action] = [],
        didChange: @escaping () -> Void
    ) {
        self._otpURL = otpURL
        self._code = code
        self._shouldPresent2FASetupFlow = shouldPresent2FASetupFlow
        self.actions = actions
        self.didChange = didChange
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
                DS.TextField(title, text: .constant(code.totpFormated()), actions: {
                    otpSubviewView
                    ForEach(actions, id: \.id) { action in
                        switch action {
                        case .copy(let action):
                            TextFieldAction.Button(L10n.Core.kwCopy, image: .ds.action.copy.outlined) { action(code, fiberFieldType) }
                        }
                    }
                })
                .editionDisabled()
                .textFieldDisabledEditionAppearance(.emphasized)
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
        .alert(isPresented: $isDeleteAlertPresented, content: deleteAlert)
    }

    @ViewBuilder
    private var otpSubviewView: some View {
        switch otpInfo?.type {
        case .totp(let period):
            TOTPView(code: $code, token: otpInfo!, period: period)
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
            return ActionSheet(title: Text(title),
                               message: nil,
                               buttons: [
                                .destructive(Text(L10n.Core.kwOtpSecretDelete), action: presentDelete),
                                .cancel()])
        } else {
            return ActionSheet(title: Text(title),
                               message: nil,
                               buttons: [
                                .destructive(Text(L10n.Core.kwOtpSecretDelete), action: presentDelete),
                                .cancel()])
        }
    }

    private func presentDelete() {
        self.isDeleteAlertPresented = true
    }

    private func deleteAlert() -> Alert {
        Alert(title: Text(L10n.Core.kwOtpsecretWarningDeletionTitle),
              message: Text(L10n.Core.kwOtpsecretWarningDeletionMessage),
              primaryButton: .destructive(Text(L10n.Core.kwOtpsecretWarningConfirmButton), action: delete),
              secondaryButton: .cancel())
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
            TOTPDetailField(otpURL: .constant(URL(string: "_")), code: .constant(""), shouldPresent2FASetupFlow: .constant(false)) { }
                .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
            TOTPDetailField(otpURL: .constant(URL(string: "")), code: .constant(""), shouldPresent2FASetupFlow: .constant(false)) { }
                .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
            TOTPDetailField(otpURL: .constant(URL(string: "_")), code: .constant(""), shouldPresent2FASetupFlow: .constant(false)) { }
                .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
        }

    }
}
#endif
