import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

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
          Text(CoreL10n.passwordTipsMainTitle)
            .textStyle(.title.section.large)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(Color.ds.text.neutral.catchy)
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
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .onAppear {
      self.completion(.shown)
    }.reportPageAppearance(.accountCreationPasswordTips)
  }

  private var navBarView: some View {
    HStack(alignment: .center) {
      Button(action: dismiss.callAsFunction) {
        Text(CoreL10n.passwordTipsCloseButton)
          .fixedSize(horizontal: true, vertical: false)
          .foregroundStyle(Color.ds.text.neutral.standard)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      Text(CoreL10n.passwordTipsNavBarTitle)
        .frame(alignment: .center)
        .fixedSize(horizontal: true, vertical: false)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Spacer()
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .frame(height: navBarHeight)
    .padding(.horizontal, 25)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }
}

struct PasswordTipsView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordTipsView { _ in }
  }
}
