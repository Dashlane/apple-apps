import SwiftUI
import UIDelight

struct PasswordGeneratorTabView: View {

    let viewModel: PasswordGeneratorTabViewModel

    @Environment(\.popoverNavigator)
    var navigator

    @ObservedObject
    var passwordGeneratorViewModel: PasswordGeneratorViewModel

    @Environment(\.toast)
    var toast

    init(viewModel: PasswordGeneratorTabViewModel) {
        self.viewModel = viewModel
        self.passwordGeneratorViewModel = viewModel.passwordGeneratorViewModel
    }
    
    var body: some View {
        form
            .frame(maxHeight: .infinity)
            .font(Font.system(size: 13))
            .onAppear(perform: {
                passwordGeneratorViewModel.refresh()
            })
            .navigator(navigator)
        }

    private func pushHistoryView() {
        guard let navigator = navigator else {
            assertionFailure()
            return
        }
        navigator.push(PasswordGeneratorHistoryView(viewModel: viewModel.makeHistoryViewModel(), pasteboardService: viewModel.pasteboardService))
    }
    
    @ViewBuilder
    var form: some View {
        VStack(alignment: .leading, spacing: 24) {
            passwordView
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                PasswordGeneratorSliderView(preferences: $passwordGeneratorViewModel.preferences)
                    .font(Typography.caption)
                PasswordGeneratorViewOptions(preferences: $passwordGeneratorViewModel.preferences)
                    .font(Typography.caption)
                HStack {
                    Spacer()
                    PasswordGeneratorSaveDefaultView(isDifferentFromDefaultConfiguration: passwordGeneratorViewModel.isDifferentFromDefaultConfiguration,
                                                     savePreferences: passwordGeneratorViewModel.savePreferences)
                }
            }
            .padding(.horizontal)
        }
    }
    
    var passwordView: some View {
        VStack(spacing: 24) {
            PasswordSlotMachine(viewModel: passwordGeneratorViewModel)
                .font(Typography.caption)
                .frame(height: 120)
            HStack(spacing: 12) {
                Spacer()
                historyButton
                copyButton
            }
        }
    }
    
        var copyButton: some View {
        Button(L10n.Localizable.passwordGeneratorCopyButton, action: {
            self.passwordGeneratorViewModel.performMainAction()
            toast(L10n.Localizable.passwordGeneratorCopiedPassword, image: .ds.action.copy.outlined)
        } )
        .buttonStyle(DashlaneDefaultButtonStyle())
        .frame(height: 32)

    }

        var historyButton: some View {
        Button(L10n.Localizable.safariShowHistory, action: { pushHistoryView() })
            .buttonStyle(DashlaneDefaultButtonStyle(backgroundColor: .clear,
                                                    borderColor: Color(asset: Asset.selection),
                                                    foregroundColor: Color(asset: Asset.primaryHighlight)))
            .frame(height: 32)
    }
}

struct PasswordGeneratorTabView_Previews: PreviewProvider {

    static var previews: some View {
        PopoverPreviewScheme(size: .popoverContent) {
            PasswordGeneratorTabView(viewModel: PasswordGeneratorTabViewModel.mock())
        }
    }
}
