import SwiftUI
import UIDelight
import DesignSystem

struct OnboardingChecklistBanner: View {
    @ObservedObject
    var model: OnboardingChecklistViewModel

    let action: () -> Void

    var body: some View {
        if let onboardingAction = model.selectedAction {
            Button(action: action) {
                Text(onboardingAction.title)
                    .foregroundColor(.ds.text.inverse.catchy)
                    .font(.headline)
            }
            .buttonStyle(OnboardingChecklistBannerButtonStyle(index: String(format: "%.2d", onboardingAction.index)))
            .padding(16)
            .background(.ds.container.agnostic.neutral.standard)
        }
    }
}

private struct OnboardingChecklistBannerButtonStyle: ButtonStyle {

    private let backgroundColor: Color = .ds.container.expressive.brand.catchy.idle
    let index: String

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top) {
            Text(index)
                .alignmentGuide(.top, computeValue: { _ in -3 })
                .foregroundColor(.ds.text.inverse.quiet)
                .font(.footnote.weight(.bold))
                .frame(height: 18)

            configuration.label
        }
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .padding(.horizontal, 16)
        .background(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
        .cornerRadius(8)
    }
}

struct OnboardingChecklistBanner_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            OnboardingChecklistBanner(model: .mock, action: {})
        }
    }
}
