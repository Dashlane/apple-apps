import SwiftUI
import TOTPGenerator
import VaultKit
import CoreLocalization

struct DetailsTOTPField: View {
    
    let title: String = CoreLocalization.L10n.Core.KWAuthentifiantIOS.otp
    static let duration: TimeInterval = 30.0
    
    @Binding
    var otpURL: URL?
    
    let otpInfo: OTPConfiguration
    
    @State
    var code: String = ""
    
    @State
    private var progress: CGFloat = 0.1
    
    @State
    var counter: UInt64 = 0
    
    let copy: (String) -> Void
    
    let didChange: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
                    .font(Typography.caption)
                
                HStack {
                    ZStack {
                        Text(code.totpFormated())
                            .foregroundColor(Color(asset: Asset.primaryHighlight))
                            .font(Typography.body)
                            .id(code)
                            .transition(AnyTransition.asymmetric(insertion: .move(edge: .top),
                                                                 removal: .move(edge: .bottom)).combined(with: .opacity))
                    }
                    .animation(.default, value: code)
                    switch otpInfo.type {
                    case .totp(let period):
                        TOTPView(code: $code, token: otpInfo, period: period)
                    case .hotp(let counter):
                        HOTPView(model: otpInfo, code: $code, initialCounter: counter, counter: $counter, didChange: {
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
                                otpURL = updatedUrl
                                self.didChange()
                            }
                        })
                    }
                }
            }
            Spacer()
            if isHovered {
                copyButton
            }
        }
        .onHover(perform: { hovering in
            isHovered = hovering
        })
    }
    
    @ViewBuilder
    var copyButton: some View {
        RowActionButton(enabled: !code.isEmpty,
                        action: { copy(code) },
                        label: Image(asset: Asset.copyInfo))
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

struct DetailsTOTPField_Previews: PreviewProvider {
    static var previews: some View {
        DetailsTOTPField(otpURL: .constant(URL(string: "_")!), otpInfo: try! OTPConfiguration(otpURL: URL(string: "_")!), copy: {_ in}, didChange: {})
    }
}
