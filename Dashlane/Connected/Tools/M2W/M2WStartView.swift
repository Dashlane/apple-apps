import DesignSystem
import Lottie
import SwiftUI
import SwiftUILottie
import UIDelight

struct M2WStartView: View {

  enum Action {
    case didTapSkip
    case didTapConnect
  }

  @Environment(\.colorScheme)
  private var colorScheme

  let completion: (Action) -> Void

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      mainContent

      Spacer()

      ctaButton
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(L10n.Localizable.m2WStartScreenSkip) {
        completion(.didTapSkip)
      }
      .foregroundStyle(Color.ds.text.brand.standard)
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    VStack {
      Text(L10n.Localizable.m2WStartScreenTitle)
        .frame(maxWidth: 400)
        .textStyle(.specialty.spotlight.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.center)

      Spacer()
        .frame(height: 16)

      LottieView(.m2WStartScreen)
        .frame(height: 122)
        .padding(.horizontal, 32)

      Spacer()
        .frame(height: 16)

      Text(L10n.Localizable.m2WStartScreenSubtitle)
        .frame(maxWidth: 400)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 32)
  }

  @ViewBuilder
  private var ctaButton: some View {
    Button(L10n.Localizable.m2WStartScreenCTA) {
      completion(.didTapConnect)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.horizontal, 16)
    .padding(.bottom, 30)
  }
}

#Preview {
  M2WStartView { _ in

  }
}
