import Foundation
import SwiftUI
import UIDelight
import DesignSystem

struct HelpView: View {
    
    let addAction: (_ skipIntro: Bool) -> Void
    
    enum HelpItem: String, Identifiable {
        var id: String {
            rawValue
        }
        case dashlaneHelp
        case tokensHelp
        case helpCenter
    }
    
    @State
    var helpItem: HelpItem?
    
    @State
    var showAdd = false
    
    var body: some View {
        list
            .navigationBarStyle(.default)
            .navigationTitle(L10n.Localizable.addOtpFlowHelpCta)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .sheet(item: $helpItem, onDismiss: {
                if showAdd {
                    showAdd = false
                    addAction(false)
                }
            }) {  item in
                switch item {
                case .dashlaneHelp:
                   onboardingView
                case .tokensHelp:
                    tokenHelpView
                case .helpCenter:
                    InApplicationSafariView(url: UserSupportURL.helpCenter.url)
                }
            }
    }
    
    var list: some View {
        VStack(alignment: .leading, spacing: 16) {
            helpButton(title: L10n.Localizable.helpDashlaneCta, action: {
                helpItem = .dashlaneHelp
            })
            helpButton(title: L10n.Localizable.help2FaCta, action: {
                addAction(true)
            })
            helpButton(title: L10n.Localizable.helpTokenCta, action: {
                helpItem = .tokensHelp
            })
            helpButton(title: L10n.Localizable.helpCenterCta, action: {
                helpItem = .helpCenter
            })
            Spacer()
        }.padding(24)
    }
    
    func helpButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            HStack {
                Text(title)
                    .foregroundColor(.ds.text.neutral.standard)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        })
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.ds.container.agnostic.neutral.supershy))
    }
    
    var tokenHelpView: some View {
        NavigationView {
            TokenHelpView(title: L10n.Localizable.helpTokenTitle,
                          message: L10n.Localizable.helpTokenMessage,
                          cta: L10n.Localizable.addOtpFlowAddNewCta,
                          completion: {
                helpItem = nil
                showAdd = true
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        helpItem = nil
                    }, title: L10n.Localizable.buttonClose)
                }
            }
        }
    }
    
    var onboardingView: some View {
        NavigationView {
            OnboardingView() {
                helpItem = nil
                showAdd = true }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        helpItem = nil
                    }, title: L10n.Localizable.buttonClose)
                }
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HelpView() { _ in }
        }
    }
}
