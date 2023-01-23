import SwiftUI
import UIDelight

struct GuidedOnboardingAnswerView: View {

    @ObservedObject
    var viewModel: GuidedOnboardingAnswerViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 18.0) {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(viewModel.content.title)
                    .font(.system(size: 17.0, weight: .semibold))
                    .foregroundColor(viewModel.tintColor)

                Text(viewModel.content.description)
                    .font(.system(size: 17.0))
                    .foregroundColor(Color.black)
                    .lineSpacing(1.35)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden(!viewModel.isExpanded)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 26, leading: 16, bottom: 26, trailing: 16))
        .background(Color(asset: FiberAsset.fixedGrayBackground))
        .cornerRadius(8.0)
        .opacity(viewModel.isInvisible ? 0.0 : 1.0)
    }
}

struct GuidedOnboardingAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            GuidedOnboardingAnswerView(viewModel: GuidedOnboardingAnswerViewModel(content: .autofill))
            GuidedOnboardingAnswerView(viewModel: GuidedOnboardingAnswerViewModel(content: .autofill))
        }.previewLayout(.sizeThatFits)
    }
}
