import NotificationKit

extension VaultFlowViewModel {
    func makeAddItemFlowViewModel() -> AddItemFlowViewModel {
        addItemFlowViewModelFactory.make(displayMode: addItemFlowDisplayMode) { [weak self] completion in
            switch completion {
            case .dismiss:
                self?.showAddItemFlow = false
            }
            self?.reportAddItemFlowDismissed()
        }
    }

    func makeAutofillOnboardingFlowViewModel() -> AutofillOnboardingFlowViewModel {
        autofillOnboardingFlowViewModelFactory.make { [weak self] in
            self?.showAutofillFlow = false
        }
    }

    func makeOnboardingChecklistFlowViewModel() -> OnboardingChecklistFlowViewModel {
        onboardingChecklistFlowViewModelFactory.make(displayMode: .modal) { [weak self] completion in
            switch completion {
            case .dismiss:
                self?.showOnboardingChecklist = false
            }
        }
    }
}
