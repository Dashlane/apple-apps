import SwiftUI
import UIDelight
import UIComponents

struct MiniBrowser: View {

    @ObservedObject
    var model: MiniBrowserViewModel

    @State
    var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(asset: FiberAsset.mainGreen).edgesIgnoringSafeArea(.bottom)

                WebView(url: model.passwordChangeUrl ?? model.url) 
                .navigationTitle(Text("🔒 " + model.domain))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton(label: L10n.Localizable.dwmOnboardingMiniBrowserBack, action: model.back)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationBarButton(L10n.Localizable.dwmOnboardingMiniBrowserDone, action: model.done)
                    }
                }

                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        MiniBrowserCardView(model: model.cardViewModel, maxHeight: cardViewMaxHeight(for: proxy.size.height), collapsed: $model.cardCollapsed).edgesIgnoringSafeArea(.bottom)

                        KeyboardSpacer().onSizeChange { size in
                            self.keyboardHeight = size.height
                            if size.height > 0 {
                                self.model.cardCollapsed = true
                            }
                        }
                    }.background(Color(asset: FiberAsset.mainGreen))
                }
            }.ignoresSafeArea(.keyboard)
        }
    }

    private func cardViewMaxHeight(for availableHeight: CGFloat) -> CGFloat {
                return min(availableHeight * 0.9, 305)
    }
}

struct MiniBrowser_Previews: PreviewProvider {

    static var model: MiniBrowserViewModel {
        MiniBrowserViewModel.mock(url: URL(string: "_")!, domain: "linkedin.com")
    }

    static var previews: some View {
        NavigationView {
            MiniBrowser(model: model)
        }
    }
}
