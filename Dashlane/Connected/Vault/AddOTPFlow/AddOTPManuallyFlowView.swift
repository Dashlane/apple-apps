import Foundation
import SwiftTreats
import SwiftUI
import UIDelight
import TOTPGenerator
import CoreSync
import CorePersonalData
import VaultKit
import AuthenticatorKit
import DesignSystem

struct AddOTPManuallyFlowView: View {

    @StateObject
    private var viewModel: AddOTPManuallyFlowViewModel

    init(viewModel: @autoclosure @escaping () -> AddOTPManuallyFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .manuallyChooseWebsite(viewModel):
                ChooseWebsiteView(viewModel: viewModel)
            case let .enterLoginDetails(viewModel):
                AddLoginDetailsView(viewModel: viewModel)
            case let .chooseCredential(viewModel):
                MatchingCredentialsListView(viewModel: viewModel)
            case let .enterToken(viewModel):
                AddOTPSecretKeyView(viewModel: viewModel)
            case let .success(mode, configuration):
                AddOTPSuccessView(mode: mode, action: {
                    viewModel.handleSuccessCompletion(for: mode, configuration: configuration)
                })
            case let .addCredential(viewModel):
                CredentialDetailView(model: viewModel).navigationBarHidden(true)
            }
        }
        .accentColor(.ds.text.brand.standard)
    }
}

struct AddOTPManuallyFlowView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyView()
        }
        .sheet(isPresented: .constant(true), onDismiss: nil) {
            AddOTPManuallyFlowView(viewModel: .mock)
        }
    }
}
