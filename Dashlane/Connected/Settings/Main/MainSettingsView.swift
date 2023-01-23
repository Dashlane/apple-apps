import SwiftUI
import SwiftTreats
import DashTypes
import CoreSession
import UIDelight
import NotificationKit

struct MainSettingsView: View {

    enum Action {
        case displaySecuritySettings
        case displayGeneralSettings
        case displayHelpCenter
        case displayLabs
    }

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    var viewModel: MainSettingsViewModel

    @State
    private var isPresentingRatingView = false

    let action: (Action) -> Void

    init(viewModel: @escaping @autoclosure () -> MainSettingsViewModel,
         action: @escaping (Action) -> Void) {
        self._viewModel = .init(wrappedValue: viewModel())
        self.action = action
    }

    var body: some View {
        List {
            SettingsStatusSection(model: viewModel.settingsStatusSectionViewModelFactory.make())

            Section {
                Button(action: { action(.displaySecuritySettings) }, label: {
                    NavigationLink(isActive: .constant(false), destination: {}, label: {
                        Text(L10n.Localizable.kwSecurity)
                            .foregroundColor(.primary)
                    })
                })

                Button(action: { action(.displayGeneralSettings) }, label: {
                    NavigationLink(isActive: .constant(false), destination: {}, label: {
                        Text(L10n.Localizable.kwGeneral)
                            .foregroundColor(.primary)
                    })
                })

                Button(action: { action(.displayHelpCenter) }, label: {
                    NavigationLink(isActive: .constant(false), destination: {}, label: {
                        Text(L10n.Localizable.helpCenterTitle)
                            .foregroundColor(.primary)
                    })
                })
            }

            Section {
                Button(action: viewModel.inviteFriends) {
                    Text(L10n.Localizable.kwInviteFriends)
                        .foregroundColor(.primary)
                }
                .activitySheet($viewModel.activityItem)

                Button(action: {
                    isPresentingRatingView = true
                }, label: {
                    Text(L10n.Localizable.kwRateDashlane)
                        .foregroundColor(.primary)
                })

                if viewModel.shouldDisplayLabs {
                    Button(action: { action(.displayLabs) }, label: {
                        NavigationLink(isActive: .constant(false), destination: {}, label: {
                            Text(L10n.Localizable.internalDashlaneLabsSettingsButton)
                                .foregroundColor(.primary)
                        })
                    })
                }
            } footer: {
                informationFooter(display: Device.isMac)
            }

            if !Device.isMac {
                Section {
                    Button(action: viewModel.lock) {
                        Text(L10n.Localizable.kwLockNow)
                            .foregroundColor(.primary)
                    }
                } footer: {
                    informationFooter(display: !Device.isMac)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(Device.isIpadOrMac ? .inline : .large)
        .navigationTitle(L10n.Localizable.kwSettings)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarItemContent
            }
        }
        .navigationViewStyle(.stack)
        .overFullScreen(isPresented: $isPresentingRatingView) {
            RateAppView(viewModel: .init(login: viewModel.login,
                                         sender: .settings,
                                         userSettings: viewModel.userSettings))
        }
        .reportPageAppearance(.settings)

        .onReceive(viewModel.deepLinkPublisher) { link in
            switch link {
            case .root:
                break
            case .security:
                action(.displaySecuritySettings)
            }
        }
    }

    @ViewBuilder
    private func informationFooter(display: Bool) -> some View {
        if display {
            Text("\(viewModel.session.configuration.login.email)\n\(footerVersionBuild)")
        }
    }

    @ViewBuilder
    private var toolbarItemContent: some View {
        if Device.isIpadOrMac {
            Button(L10n.Localizable.kwDoneButton, action: dismiss.callAsFunction)
        }
    }

    private var footerVersionBuild: String {
        let base = "Dashlane v\(Application.version())"
        guard let information = Application.versionBuildOriginInformation() else {
            return base
        }
        return "\(base) - \(information)"
    }
}

struct MainSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MainSettingsView(viewModel: MainSettingsViewModel.mock(), action: { _ in })
    }
}
