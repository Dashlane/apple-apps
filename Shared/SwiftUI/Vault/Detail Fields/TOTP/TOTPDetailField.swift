import SwiftUI
import TOTPGenerator
import Combine
import UIDelight
import SwiftTreats

struct TOTPDetailField: View {

    let title: String = L10n.Localizable.credentialDetailViewOtpFieldLabel
    @Binding
    var otpURL: URL?

    @Binding
    var code: String
   
    @Binding
    var shouldPresent2FASetupFlow: Bool
  
    let didChange: () -> Void

    @State
    var isActionSheetPresented: Bool = false

    @State
    var isDeleteAlertPresented: Bool = false

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.detailFieldType)
    var fiberFieldType

    var otpInfo: OTPConfiguration? {
        guard let otpURL = otpURL else {
            return nil
        }
        return try? OTPConfiguration(otpURL: otpURL)
    }
    
    @State
    var counter: UInt64 = 0
    
    @ViewBuilder
    var body: some View {
        if otpInfo == nil && !Device.isMac  {
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
            Image(asset: SharedAsset.paywallIconShield)
                .resizable()
                .frame(width: 23, height: 23)
                .foregroundColor(Color(asset: FiberAsset.accentColor))
            Button(L10n.Localizable._2faSetupCta) {
                shouldPresent2FASetupFlow = true
            }
            .foregroundColor(Color(asset: FiberAsset.mainCopy))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(asset: FiberAsset.accentColor))
        }
        .labeled(title)
        .padding(.vertical, 5)
    }
    
    var otpView: some View {
        HStack {
            ZStack {
                Text(code.totpFormated())
                    .id(code)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .top),
                                                         removal: .move(edge: .bottom)).combined(with: .opacity))
            }
            .animation(.default, value: code)
            .frame(maxWidth: .infinity, alignment: .leading)
            .labeled(title)
            switch otpInfo?.type {
            case .totp(let period):
                TOTPView(code: $code, token: otpInfo!, period: period)
            case .hotp(let counter):
                HOTPView(model: otpInfo!, code: $code, initialCounter: counter, counter: $counter) {
                    guard let url = otpURL else {
                        return
                    }
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    var items = components?.queryItems?.filter {
                        $0.name != "counter"
                    }
                    items?.append(URLQueryItem(name: "counter", value: String(self.counter)))
                    components?.queryItems = items
                    if let updatedUrl = components?.url {
                        self.otpURL = updatedUrl
                        self.didChange()
                    }
                }
            case nil:
                EmptyView()
            }
        }
        .contentShape(Rectangle())
        .actionSheet(isPresented: $isActionSheetPresented, content: actionSheet)
        .alert(isPresented: $isDeleteAlertPresented, content: deleteAlert)
    }

    private func actionSheet() -> ActionSheet {
        if Device.isMac {
            return ActionSheet(title: Text(title),
                               message: nil,
                               buttons: [
                                .destructive(Text(L10n.Localizable.kwOtpSecretDelete), action: presentDelete),
                                .cancel()])
        }
        else {
            return ActionSheet(title: Text(title),
                               message: nil,
                               buttons: [
                                .destructive(Text(L10n.Localizable.kwOtpSecretDelete), action: presentDelete),
                                .cancel()])
        }
    }

    private func presentDelete() {
        self.isDeleteAlertPresented = true
    }

    private func deleteAlert() -> Alert {
        Alert(title: Text(L10n.Localizable.kwOtpsecretWarningDeletionTitle),
              message: Text(L10n.Localizable.kwOtpsecretWarningDeletionMessage),
              primaryButton: .destructive(Text(L10n.Localizable.kwOtpsecretWarningConfirmButton), action: delete),
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
            TOTPDetailField(otpURL: .constant(URL(string:"_")), code: .constant(""), shouldPresent2FASetupFlow: .constant(false)) { }
                .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
            TOTPDetailField(otpURL: .constant(URL(string: "")), code: .constant(""), shouldPresent2FASetupFlow: .constant(false)) { }
                .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
            TOTPDetailField(otpURL: .constant(URL(string: "_")), code: .constant(""), shouldPresent2FASetupFlow: .constant(false)) { }
                .previewLayout(.sizeThatFits).environment(\.detailMode, .updating)
        }

    }
}
