import SwiftUI
import CorePersonalData
import UIDelight
import TOTPGenerator
import DashlaneAppKit
import VaultKit

struct CredentialDetailsView: View {
    
    @ObservedObject
    var viewModel: CredentialDetailsViewModel
    
    @State
    var navigationBarColor = Color(asset: Asset.dashlaneColorTealBackground)
    
    @Environment(\.toast)
    var toast
    
    @Environment(\.popoverNavigator)
    var navigator
    
    var body: some View {
        structure
            .navigationBar(style: navigationStyle)
            .task {
                let backgroundColor = try? await viewModel.iconViewModel.backgroundColor(for: viewModel.credential)
                navigationBarColor = backgroundColor ?? Color(asset: Asset.dashlaneColorTealBackground)
            }
    }
    
    var navigationStyle: PopoverNavigationBarStyle {
        return .details(.init(thumbnail: VaultItemIconView(model: viewModel.iconViewModel),
                              title: titleView.eraseToAnyView(),
                              trailingAction: editCredentialAction,
                              backgroundColor: navigationBarColor,
                              tintColor: navigationBarColor.contentTintColor()
        ))
    }
    
    var editCredentialAction: NavigationAction {
        NavigationAction(image: Asset.edit,
                         action: { viewModel.edit() })
    }
    
    var titleView: some View {
        Text(viewModel.credential.displayTitle)
            .font(Typography.title)
            .lineLimit(1)
    }
}

extension CredentialDetailsView {
    
    @ViewBuilder
    var structure: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !viewModel.credential.email.isEmpty {
                    DetailsBasicField(title: L10n.Localizable.KWAuthentifiantIOS.email,
                                      value: viewModel.credential.email,
                                      copy: { copy($0, action: .email) })
                        .fieldFrame()
                }
                if !viewModel.credential.login.isEmpty {
                    DetailsBasicField(title: L10n.Localizable.KWAuthentifiantIOS.login,
                                      value: viewModel.credential.login,
                                      copy: { copy($0, action: .login) })
                        .fieldFrame()
                }
                if !viewModel.credential.secondaryLogin.isEmpty {
                    DetailsBasicField(title: L10n.Localizable.KWAuthentifiantIOS.secondaryLogin,
                                      value: viewModel.credential.secondaryLogin,
                                      copy: { copy($0, action: .secondaryLogin) })
                        .fieldFrame()
                }
                if !viewModel.credential.password.isEmpty {
                    DetailsSecureField(title: L10n.Localizable.KWAuthentifiantIOS.password,
                                       value: viewModel.credential.password,
                                       enabled: !viewModel.isLimited(),
                                       copy: { copy($0, action: .password(limited: viewModel.isLimited())) })
                        .fieldFrame()
                }

                if let url = viewModel.credential.url {
                    DetailsURLField(title: L10n.Localizable.KWAuthentifiantIOS.url,
                                    value: url,
                                    openWebsite: viewModel.openWebsite(_:))
                        .fieldFrame()
                }
                
                if let otpURL = viewModel.credential.otpURL, let otpInfos = try? OTPConfiguration(otpURL: otpURL) {
                    DetailsTOTPField(otpURL: $viewModel.credential.otpURL, otpInfo: otpInfos,
                                     copy: { copy($0, action: .oneTimePassword) }, didChange: {
                                        
                                     })
                        .fieldFrame()
                }
                
                if !viewModel.credential.note.isEmpty {
                    DetailsNoteField(title: L10n.Localizable.KWAuthentifiantIOS.note,
                                     value: viewModel.credential.note,
                                     copy: { copy($0, action: .note) })
                        .frame(minHeight: 70)
                }
                
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func copy(_ value: String, action: CopyCredentialAction) {
        self.viewModel.copy(value: value)
        toast(action, for: viewModel.credential)
    }
}

private extension View {
    func fieldFrame() -> some View {
        frame(height: 70)
    }
}

struct CredentialDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme(size: .custom(400, 400)) {
            CredentialDetailsView(viewModel: CredentialDetailsViewModel.mock())
        }
    }
}

private extension VaultItemIconViewModel {
    func backgroundColor(for credential: Credential) async throws -> SwiftUI.Color {
        guard let nsColor = try await iconLibrary.icon(for: credential, usingLargeImage: false)?.colors?.backgroundColor else {
            return Color(asset: Asset.dashlaneColorTealBackground)
        }
        return SwiftUI.Color(nsColor)
    }
}

private extension SwiftUI.Color {
    func contentTintColor() -> SwiftUI.Color {
        guard let grayedColor = NSColor(self).usingColorSpace(.deviceGray) else {
            return .black
        }
        if grayedColor.whiteComponent > 0.90 {
            return .black
        } else {
            return .white
        }
    }
}
