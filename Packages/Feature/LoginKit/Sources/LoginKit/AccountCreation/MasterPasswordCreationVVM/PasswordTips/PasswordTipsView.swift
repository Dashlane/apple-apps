import SwiftUI
import DesignSystem
import UIComponents
import CoreLocalization

struct PasswordTipsView: View {

    var viewModel = PasswordTipsViewModel()

    private let navBarHeight: CGFloat = 44

    @Environment(\.dismiss)
    private var dismiss

    enum Completion {
        case shown
    }

    let completion: (Completion) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            navBarView
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Text(L10n.Core.passwordTipsMainTitle)
                        .font(DashlaneFont.custom(28, .bold).font)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.ds.text.neutral.catchy)
                    PasswordGuidelineView(viewModel: viewModel.generalRules)
                    PasswordGuidelineView(viewModel: viewModel.simpleRules)
                    PasswordGuidelineView(viewModel: viewModel.difficultRules)
                    PasswordGuidelineView(viewModel: viewModel.advancedRules)
                    Spacer()
                }
                .padding(.horizontal, 25)
            }
        }
        .frame(maxWidth: 550, maxHeight: 890)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .onAppear {
            self.completion(.shown)
        }.reportPageAppearance(.accountCreationPasswordTips)
    }

    private var navBarView: some View {
        HStack(alignment: .center) {
            Button(action: dismiss.callAsFunction) {
                Text(L10n.Core.passwordTipsCloseButton)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(.ds.text.neutral.standard)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(L10n.Core.passwordTipsNavBarTitle)
                .frame(alignment: .center)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(.ds.text.neutral.catchy)
            Spacer()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: navBarHeight)
        .padding(.horizontal, 25)
        .background(.ds.background.alternate)
    }

    struct PasswordTipsView_Previews: PreviewProvider {
        static var previews: some View {
            PasswordTipsView { _ in }
        }
    }
}
