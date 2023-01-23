import SwiftUI

struct AutofillTabView: View {

    let viewModel: AutofillTabViewModel

    var body: some View {
        AutofillView(viewModel: viewModel.currentWebsite)
    }
}
