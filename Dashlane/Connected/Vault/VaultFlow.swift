import CorePersonalData
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import NotificationKit

struct VaultFlow: View {

    @StateObject
    var viewModel: VaultFlowViewModel

    init(viewModel: @autoclosure @escaping () -> VaultFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .list(let model):
                HomeView(model: model)
            case .category(let model):
                VaultListView(model: model, shouldHideFilters: true)
            case .detail(let view):
                detailView(view)
            case .autofillDemoDummyFields(let credential):
                autofillDemoDummyFields(credential)
            }
        }
        .navigationBarStyle(.init(tintColor: .ds.text.neutral.catchy, backgroundColor: .ds.background.default))
        .fullScreenCoverOrSheet(isPresented: $viewModel.showAddItemFlow) {
            NavigationView {
                viewModel.makeAddItemFlowViewModel().map { AddItemFlow(viewModel: $0) }
            }
        }
        .sheet(isPresented: $viewModel.showAutofillFlow) {
            AutofillOnboardingFlowView(model: viewModel.makeAutofillOnboardingFlowViewModel())
        }
        .sheet(item: $viewModel.autofillDemoDummyFieldsCredential) { credential in
            autofillDemoDummyFields(credential)
        }
        .sheet(isPresented: $viewModel.showOnboardingChecklist) {
            OnboardingChecklistFlow(viewModel: viewModel.makeOnboardingChecklistFlowViewModel())
        }
    }

    @ViewBuilder
    private func autofillDemoDummyFields(_ credential: Credential) -> some View {
        viewModel.autofillDemoDummyFields(
            credential: credential,
            completion: { viewModel.handleAutofillDemoDummyFieldsAction($0) }
        )
    }

    @ViewBuilder
    private func detailView(_ view: some View) -> some View {
        view
            .navigationBarHidden(true)
            .hideNavigationBar()
            .hideTabBar()
    }
}

private extension View {

            @ViewBuilder
    func fullScreenCoverOrSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        if Device.isIpadOrMac {
            sheet(isPresented: isPresented, content: content)
        } else {
            fullScreenCover(isPresented: isPresented, content: content)
        }
    }
}
