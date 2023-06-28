import SwiftUI

struct AutofillTabView: View {

    let viewModel: AutofillTabViewModel

    var body: some View {
        if viewModel.isSafariDisabled {
            SafariDisabledOnboardingView()
        } else {
            AutofillView(viewModel: viewModel.currentWebsite)
        }
    }
}
