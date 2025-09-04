import CoreLocalization
import DesignSystem
import Lottie
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight
import UserTrackingFoundation

struct AutofillOnboardingIntroView: View {
  let model: AutofillOnboardingIntroViewModel
  @State private var selection = AutofillTutorialPage.login
  @AccessibilityFocusState var isHeaderFocused: Bool

  enum AutofillTutorialPage {
    case login
    case generatePasswords
    case sync
  }

  var body: some View {
    VStack(spacing: 20) {
      TabView(selection: $selection) {
        pageView(
          for: .lottie(.autofillBannerTutorial),
          title: CoreL10n.autofillDemoFieldsLoginTitle,
          message: CoreL10n.autofillDemoFieldsLoginText
        )
        .tag(AutofillTutorialPage.login)
        pageView(
          for: .image(Image(.autofillTutorialGenerate)),
          title: CoreL10n.autofillDemoFieldsGenerateTitle,
          message: CoreL10n.autofillDemoFieldsGenerateText
        )
        .tag(AutofillTutorialPage.generatePasswords)
        if model.shouldShowSync {
          pageView(
            for: .image(Image(.autofillTutorialSync)),
            title: CoreL10n.autofillDemoFieldsSyncTitle,
            message: CoreL10n.autofillDemoFieldsSyncText
          )
          .tag(AutofillTutorialPage.sync)

        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

      Button(CoreL10n.autofillDemoFieldsAction) {
        model.action()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.isHeaderFocused = true
      }
      model.report(page: selection)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.kwButtonClose) {
          model.dismiss()
        }
        .foregroundStyle(Color.ds.text.neutral.catchy)
      }
    }
    .onChange(of: selection) { _, selectedPageIndex in
      model.report(page: selectedPageIndex)
    }
    .navigationBarBackButtonHidden(true)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  enum ItemAsset {
    case image(Image)
    case lottie(LottieAsset)
  }

  @ViewBuilder
  func view(for asset: ItemAsset) -> some View {
    switch asset {
    case .image(let image):
      image
    case .lottie(let lottie):
      LottieView(lottie)
        .frame(width: 375, height: 229)
    }
  }

  @ViewBuilder
  func pageView(for asset: ItemAsset, title: String, message: String) -> some View {
    ScrollView {
      VStack(spacing: 20) {
        Spacer()
        view(for: asset)
          .padding(.bottom, 20)
        Text(title)
          .textStyle(.specialty.spotlight.medium)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.horizontal, 24)
        Text(message)
          .multilineTextAlignment(.center)
          .textStyle(.specialty.spotlight.small)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.horizontal, 24)
        Spacer()
      }
    }
  }
}

#Preview {
  AutofillOnboardingIntroView(
    model: .init(shouldShowSync: true, activityReporter: .mock, action: {}, dismiss: {}))
}
