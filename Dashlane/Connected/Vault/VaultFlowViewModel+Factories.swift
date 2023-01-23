import NotificationKit

extension VaultFlowViewModel {
    func makeAddItemFlowViewModel() -> AddItemFlowViewModel? {
        guard let addItemFlowDisplayMode else {
            showAddItemFlow = false
            return nil
        }
        return addItemFlowViewModelFactory.make(displayMode: addItemFlowDisplayMode) { [weak self] completion in
            switch completion {
            case .dismiss:
                self?.showAddItemFlow = false
                self?.addItemFlowDisplayMode = nil
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
