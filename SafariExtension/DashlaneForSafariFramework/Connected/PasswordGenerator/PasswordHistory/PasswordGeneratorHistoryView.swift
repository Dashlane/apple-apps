import SwiftUI
import CorePersonalData
import Combine
import UIDelight
import UIComponents
import VaultKit

struct PasswordGeneratorHistoryView: View {

    @ObservedObject
    var viewModel: PasswordGeneratorHistoryViewModel

    var pasteboardService: PasteboardService

    var navigationStyle: PopoverNavigationBarStyle {
        return .default(DefaultNavigation(title: L10n.Localizable.safariPasswordGeneratedHistoryTitle, trailingAction: nil))
    }

    var body: some View {
        Group {
            switch viewModel.state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())

                case let .loaded(passwords):
                    list(for: passwords)
                case .empty:
                    emptyView
            }
        }
        .animation(.easeOut)
        .navigationBar(style: navigationStyle)
        .toasterOn()
    }

    private func list(for passwords: [DateGroup: [GeneratedPassword]]) -> some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0) {
                ForEach(DateGroup.allCases) { group in
                    Button(action: {
                    }, label: {
                        section(for: group, in: passwords)
                            .contentShape(Rectangle())
                    })
                    .buttonStyle(LightButtonStyle())
                }
                .frame(height: 60)
            }
        }
    }

    @ViewBuilder
    func section(for group: DateGroup, in passwords: [DateGroup: [GeneratedPassword]]) -> some View {
        if let passwords = passwords[group], !passwords.isEmpty {
            ForEach(passwords, id: \.id) { password in
                PasswordHistoryRowView(viewModel: PasswordHistoryRowViewModel(generatedPassword: password, pasteboardService: pasteboardService)) {
                    viewModel.copy(password)
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(asset: Asset.historyLarge)

            Text(L10n.Localizable.generatedPasswordListEmptyTitle)
        }
    }

}
