import Foundation

@MainActor
final class OnboardingChecklistFlowViewModel: ObservableObject, SessionServicesInjecting, OnboardingChecklistActionHandler {

    enum Completion {
        case dismiss
    }

    enum Action {
        case addNewItem(displayMode: AddItemFlowViewModel.DisplayMode)
        case ctaTapped(action: OnboardingChecklistAction)
        case onDismiss
        case onAppear
    }

    enum DisplayMode {
        case root
        case modal
    }

    enum Step {
        case onboardingChecklist(OnboardingChecklistViewModel)
    }

        @Published
    var steps: [Step] = []

    @Published
    var genericSheet: GenericSheet?

    @Published
    var genericFullCover: GenericSheet?

    let displayMode: DisplayMode
    let origin: OnboardingChecklistOrigin = .standalone

    private let onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)?
    private let completion: (Completion) -> Void

        private let onboardingChecklistViewModelFactory: OnboardingChecklistViewModel.Factory

        let sessionServices: SessionServicesContainer

    init(
        displayMode: OnboardingChecklistFlowViewModel.DisplayMode,
        onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil,
        completion: @escaping (OnboardingChecklistFlowViewModel.Completion) -> Void,
        onboardingChecklistViewModelFactory: OnboardingChecklistViewModel.Factory,
        sessionServices: SessionServicesContainer
    ) {
        self.displayMode = displayMode
        self.onboardingChecklistViewAction = onboardingChecklistViewAction
        self.completion = completion

        self.onboardingChecklistViewModelFactory = onboardingChecklistViewModelFactory

        self.sessionServices = sessionServices

        start()
    }

    private func start() {
        steps = [.onboardingChecklist(makeOnboardingChecklistViewModel())]
    }

    func dismiss() {
        completion(.dismiss)
    }

    func dismissOnboardingChecklistFlow() {
        dismiss()
    }

    func makeOnboardingChecklistViewModel() -> OnboardingChecklistViewModel {
        return onboardingChecklistViewModelFactory.make(action: onboardingChecklistViewAction ?? { self.handleOnboardingChecklistViewAction($0) }
        )
    }
}
