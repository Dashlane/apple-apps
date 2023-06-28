import CorePersonalData
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import NotificationKit
import Combine

struct VaultFlow: TabFlow {

    let tag: Int = 0
    let id: UUID = .init()
    var title: String {
        viewModel.mode.title
    }

    var tabBarImage: NavigationImageSet {
        viewModel.mode.tabBarSet
    }

    var sidebarImage: NavigationImageSet {
        viewModel.mode.sidebarImage
    }

    let badgeValue: CurrentValueSubject<String?, Never>?

    @ObservedObject
    var viewModel: VaultFlowViewModel

    init(viewModel: VaultFlowViewModel) {
        self.viewModel = viewModel
        self.badgeValue = viewModel.badgeValues
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
                AddItemFlow(viewModel: viewModel.makeAddItemFlowViewModel())
            }
        }
        .onReceive(viewModel.deeplinkPublisher) { deeplink in
            guard Device.isIpadOrMac, self.viewModel.canHandle(deepLink: deeplink) else { return }
            self.viewModel.handle(deeplink)
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

private extension VaultFlowViewModel.Mode {
    var title: String {
        switch self {
        case .allItems:
            return L10n.Localizable.recentTitle
        case .category(let category):
            return category.title
        }
    }

    var tabBarSet: NavigationImageSet {
        switch self {
        case .allItems:
            return NavigationImageSet(
                image: .ds.home.outlined,
                selectedImage: .ds.home.filled
            )
        case .category(let category):
            return category.tabBarImage
        }
    }

    var sidebarImage: NavigationImageSet {
        switch self {
        case .allItems:
            return tabBarSet
        case .category(let category):
            return category.sidebarImage
        }
    }
}
