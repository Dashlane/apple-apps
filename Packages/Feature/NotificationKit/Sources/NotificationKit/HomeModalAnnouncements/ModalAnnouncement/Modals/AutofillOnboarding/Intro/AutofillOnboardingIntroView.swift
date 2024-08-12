import CoreLocalization
import CoreUserTracking
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

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
          title: L10n.Core.autofillDemoFieldsLoginTitle,
          message: L10n.Core.autofillDemoFieldsLoginText
        )
        .tag(AutofillTutorialPage.login)
        pageView(
          for: .image(Asset.autofillTutorialGenerate),
          title: L10n.Core.autofillDemoFieldsGenerateTitle,
          message: L10n.Core.autofillDemoFieldsGenerateText
        )
        .tag(AutofillTutorialPage.generatePasswords)
        if model.shouldShowSync {
          pageView(
            for: .image(Asset.autofillTutorialSync),
            title: L10n.Core.autofillDemoFieldsSyncTitle,
            message: L10n.Core.autofillDemoFieldsSyncText
          )
          .tag(AutofillTutorialPage.sync)

        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

      Button(L10n.Core.autofillDemoFieldsAction) {
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
        NavigationBarButton(L10n.Core.kwButtonClose) {
          model.dismiss()
        }
        .foregroundColor(.ds.text.neutral.catchy)
      }
    }
    .onChange(of: selection) { selectedPageIndex in
      model.report(page: selectedPageIndex)
    }
    .navigationBarBackButtonHidden(true)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  enum ItemAsset {
    case image(ImageAsset)
    case lottie(LottieAsset)
  }

  @ViewBuilder
  func view(for asset: ItemAsset) -> some View {
    switch asset {
    case .image(let image):
      Image(asset: image)
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
          .font(DashlaneFont.custom(26, .bold).font)
          .multilineTextAlignment(.center)
          .foregroundColor(.ds.text.neutral.catchy)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.horizontal, 24)
        Text(message)
          .multilineTextAlignment(.center)
          .font(.body)
          .foregroundColor(.ds.text.neutral.standard)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.horizontal, 24)
        Spacer()
      }
    }
  }
}

struct AutofillOnboardingIntroView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      AutofillOnboardingIntroView(
        model: .init(shouldShowSync: true, activityReporter: .mock, action: {}, dismiss: {}))
    }
  }
}
