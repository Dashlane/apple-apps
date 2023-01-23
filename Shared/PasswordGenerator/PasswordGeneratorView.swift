
import Foundation
import SwiftUI
import CorePasswords
import DashlaneReportKit
import DashTypes
import CoreSpotlight
import CorePersonalData
import CoreUserTracking
import UIDelight
import SwiftTreats
import UIComponents
import DesignSystem

struct PasswordGeneratorView: View {

    @Environment(\.dismiss)
    private var dismiss
    
    @StateObject
    var viewModel: PasswordGeneratorViewModel

    @State
    private var isInSliding  = false
    
    let userActivityCallback: (NSUserActivity) -> Void

    init(viewModel: @autoclosure @escaping () -> PasswordGeneratorViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
        #if !EXTENSION
        self.userActivityCallback = Self.update
        #else
        userActivityCallback = { _ in }
        #endif
    }

    var body: some View {
        form
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .onAppear(perform: viewModel.didViewPasswordGenerator)
            .accentColor(Color(asset: FiberAsset.accentColor))
            .userActivity(.generatePassword, userActivityCallback)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingView
                }
            }
            .navigationTitle(L10n.Localizable.tabGeneratorTitle)
            .navigationBarTitleDisplayMode(Device.isIpadOrMac ? .inline : .automatic)
            .reportPageAppearance(.passwordGenerator)
            .onAppear {
                viewModel.refresh()
            }
    }

    @ViewBuilder
    var trailingView: some View {
        switch viewModel.mode {
            case let .standalone(action):
                NavigationBarButton(action: {
                    action(.showHistory)
                }, label: {
                    Image(asset: FiberAsset.history)
                        .contentShape(Rectangle())
                        .frame(width: 24, height: 24)
                        .fiberAccessibilityLabel(Text(L10n.Localizable.generatedPasswordListTitle))
                })
            case .selection:
                EmptyView()
        }
    }

        var form: some View {
        PasswordGeneratorForm {
            Section {
                passwordView
                    .buttonStyle(PlainButtonStyle())
            }
            .listRowInsets(.init(top: 0, leading: 16, bottom: 24, trailing: 16))
            .listRowSeparator(.hidden)

            Section(header: Text(L10n.Localizable.kwPadExtensionGeneratorLength.uppercased()) + Text(": \(viewModel.preferences.length)")) {
                PasswordGeneratorSliderView(viewModel: viewModel)
            }
            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)

            Section(header: Text(L10n.Localizable.kwPadExtensionOptions.uppercased())) {
                PasswordGeneratorViewOptions(preferences: $viewModel.preferences)
                    .font(.body)
            }
            .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
        }
    }

    var passwordView: some View {
        VStack(spacing: 24) {
            PasswordSlotMachine(viewModel: viewModel)
            mainButton
        }
    }

        var mainButton: some View {
        Group {
            switch viewModel.mode {
                case let .standalone(action):
                    RoundedButton(L10n.Localizable.passwordGeneratorCopyButton, action: viewModel.performMainAction)
                        .actionSheet(item: $viewModel.pendingSaveAsCredentialPassword) { password in
                            makeSavePasswordActionSheet {
                                action(.createCredential(password: password))
                            }
                        }
                case .selection:
                    RoundedButton(L10n.Localizable.passwordGeneratorUseButton) {
                        self.viewModel.performMainAction()
                        self.dismiss()
                    }
            }
        }
        .roundedButtonLayout(.fill)
        .cornerRadius(6)
    }

    private func makeSavePasswordActionSheet(action: @escaping () -> Void) -> ActionSheet {
        ActionSheet(title: Text(L10n.Localizable.dwmOnboardingCardPWGTabEmailCopied).foregroundColor(.green),
                    message: Text(L10n.Localizable.savePasswordMessageNewpassword),
                    buttons: [.default(Text(L10n.Localizable.kwSave), action: action),
                              .cancel(Text(L10n.Localizable.kwNotSave))])

    }
}

struct PasswordGeneratorForm<Content: View>: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if Device.isIpadOrMac {
            Form(content: content)
                .scrollContentBackgroundHidden()
                .lifeCycleEvent(onWillAppear: {
                    UITableView.appearance().backgroundColor = .clear
                }, onWillDisappear: {
                    UITableView.appearance().backgroundColor = FiberAsset.tableBackground.color
                })
                .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        } else {
            List(content: content)
                .listStyle(InsetGroupedListStyle())
        }

    }
}

private extension List {
    @ViewBuilder
    func generatorListStyle() -> some View {
        if Device.isIpadOrMac {
            self.listStyle(PlainListStyle())
        } else {
            self.listStyle(InsetGroupedListStyle())
        }
    }
}

struct PasswordGeneratorView_Previews: PreviewProvider {
        static var previews: some View {
        MultiContextPreview {
                        PasswordGeneratorView(viewModel: PasswordGeneratorViewModel.mock)
                .navigationBarTitleDisplayMode(.inline)
                    }
    }
}


extension GeneratedPassword: Identifiable { }
