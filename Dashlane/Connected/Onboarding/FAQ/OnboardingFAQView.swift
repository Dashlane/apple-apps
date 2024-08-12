import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct OnboardingFAQView: View {
  var questions: [OnboardingFAQ]

  var body: some View {
    VStack {
      topView
      ScrollView {
        VStack(spacing: 0) {
          contentView
        }
      }
    }
    .background(Color.ds.background.default)
    .edgesIgnoringSafeArea(.bottom)
  }

  var topView: some View {
    HStack {
      Spacer()
      Rectangle()
        .frame(width: 35, height: 5)
        .cornerRadius(16)
        .foregroundColor(.ds.container.expressive.neutral.quiet.idle)
      Spacer()
    }.padding(.top, 6)
  }

  var contentView: some View {
    VStack(alignment: .leading, spacing: 40.0) {
      Text(L10n.Localizable.guidedOnboardingFAQTitle)
        .font(DashlaneFont.custom(26, .bold).font)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.ds.text.neutral.catchy)

      VStack {
        ForEach(questions, id: \.rawValue) { question in
          OnboardingFAQItemView(question: question)
        }
      }
    }.padding(25.0)
  }
}

struct OnboardingFAQView_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      OnboardingFAQView(questions: OnboardingFAQService().questions)
    }
  }
}
