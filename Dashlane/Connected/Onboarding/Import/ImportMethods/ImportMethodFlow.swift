import Foundation
import ImportKit
import SwiftUI
import UIDelight

struct ImportMethodFlow: View {

    @StateObject
    var viewModel: ImportMethodFlowViewModel

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .addItem(let model):
                AddItemFlow(viewModel: model)
                    .addPrefilledCredentialViewSpecificBackButton(.back)
            case .importView(let model):
                ImportMethodView(viewModel: model)
            case .chromeFlow(let flow):
                flow
            case .dashFlow(let flow):
                flow
            case .keychainFlow(let flow):
                flow
            case .keychainInstructions(let view):
                view
            }
        }
    }
}
