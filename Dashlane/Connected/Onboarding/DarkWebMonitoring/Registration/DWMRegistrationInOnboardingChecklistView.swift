import Foundation
import SwiftUI
import UIDelight
import UIComponents

struct DWMRegistrationInOnboardingChecklistView<Model: DWMRegistrationViewModelProtocol>: View {

    @ObservedObject
    var viewModel: Model

    var body: some View {
        FullScreenScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    title
                    Spacer().frame(height: 16)
                    subtitle
                    Spacer().frame(height: 40)
                }
                DWMRegistrationMenuView(viewModel: viewModel, environment: .onboardingChecklistItem)
            }
            .padding(.horizontal, 32)
        }
        .background(Color(asset: FiberAsset.appBackground))
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle(L10n.Localizable.dwmOnboardingFixBreachesMainTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(action: viewModel.back)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var title: some View {
        Text(L10n.Localizable.darkWebMonitoringOnboardingChecklistEmailConfirmationTitle)
            .bold()
            .multilineTextAlignment(.leading)
            .font(.title3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var subtitle: some View {
        Text(L10n.Localizable.darkWebMonitoringOnboardingChecklistEmailConfirmationBody(viewModel.email))
            .multilineTextAlignment(.leading)
            .foregroundColor(Color(asset: FiberAsset.neutralText))
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
    }

}

struct DWMEmailRegistrationChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            DWMRegistrationInOnboardingChecklistView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: false))
            DWMRegistrationInOnboardingChecklistView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: true))
        }
    }
}
