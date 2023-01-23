import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

struct PasswordHealthDetailedListView: View {

    @ObservedObject
    var viewModel: PasswordHealthDetailedListViewModel
    let action: (PasswordHealthView.Action) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(headline)
                .font(DashlaneFont.custom(24, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.leading)
                .padding(.top, 16)
                .padding(.horizontal, 16)

            ScrollView {
                PasswordHealthListView(viewModel: viewModel.listViewModel, action: action)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .reportPageAppearance(viewModel.kind.pageEvent)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        if viewModel.credentialsCount == 1 {
            return L10n.Localizable.passwordHealthDetailedListTitleSingular(viewModel.kind.title)
        } else {
            return L10n.Localizable.passwordHealthDetailedListTitlePlural(viewModel.kind.title)
        }
    }

    private var headline: String {
        if viewModel.credentialsCount == 1 {
            return L10n.Localizable.passwordHealthDetailedListHeadlineSingular(viewModel.credentialsCount, viewModel.kind.title.lowercasingFirstLetter())
        } else {
            return L10n.Localizable.passwordHealthDetailedListHeadlinePlural(viewModel.credentialsCount, viewModel.kind.title.lowercasingFirstLetter())
        }
    }
}

struct PasswordHealthDetailedListView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordHealthDetailedListView(viewModel: .mock) { _ in }
    }
}
