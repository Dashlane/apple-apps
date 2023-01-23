import Foundation
import Combine
import DashlaneAppKit

extension OnboardingChecklistViewModel {
    func setupSubscriptions() {
        setupSettingsPublishers()
        setupDWMPublishers()

        vaultItemsService.$credentials
            .removeDuplicates()
            .map { !$0.isEmpty }
            .filter { $0 == true } 
            .receive(on: RunLoop.main)
            .assign(to: \.hasAtLeastOnePassword, on: self)
            .store(in: &cancellables)

        autofillService.$activationStatus
            .removeDuplicates()
            .map { $0 == .enabled }
            .receive(on: RunLoop.main)
            .assign(to: \.isAutofillActivated, on: self)
            .store(in: &cancellables)

        lockService.locker.screenLocker?
            .$lock
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.modalAnnouncementsViewModel.trigger.send(.sessionUnlocked)
            }.store(in: &cancellables)

        setupSettingsUpdatePublisher()

        preLoadAnimation()
    }

    private func setupSettingsUpdatePublisher() {
        let hasSeenUnexpectedErrorPublisher: AnyPublisher<Bool, Never> = dwmOnboardingSettings.publisher(for: .hasSeenUnexpectedError).compactMap { $0 }.eraseToAnyPublisher()

        Publishers.MergeMany([$hasUserDismissedOnboardingChecklist.eraseToAnyPublisher(),
                              $hasUserUnlockedOnboardingChecklist.eraseToAnyPublisher(),
                              $hasFinishedM2WAtLeastOnce.eraseToAnyPublisher(),
                              $hasFinishedChromeImportAtLeastOnce.eraseToAnyPublisher(),
                              $hasSeenDWMExperience.eraseToAnyPublisher(),
                              $hasAtLeastOnePassword.eraseToAnyPublisher(),
                              $dwmOnboardingProgress.map { _ in true }.eraseToAnyPublisher(),
                              $hasConfirmedEmailFromOnboardingChecklist.eraseToAnyPublisher(),
                              hasSeenUnexpectedErrorPublisher,
                              $isAutofillActivated.eraseToAnyPublisher()])
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setupSelectedAction()
                self?.updateDismissability()
            }
            .store(in: &cancellables)

        Publishers.MergeMany([userSettings.settingsChangePublisher(key: .guidedOnboardingData).map { _ in true }.eraseToAnyPublisher(),
                              $dwmOnboardingProgress.map { _ in true }.eraseToAnyPublisher(),
                              $hasConfirmedEmailFromOnboardingChecklist.eraseToAnyPublisher(),
                              hasSeenUnexpectedErrorPublisher])
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setupChecklist()
            }
            .store(in: &cancellables)
    }

    private func setupSettingsPublishers() {
        userSettings.publisher(for: .hasUserDismissedOnboardingChecklist)
            .compactMap { $0 }
            .assign(to: \.hasUserDismissedOnboardingChecklist, on: self)
            .store(in: &cancellables)

        userSettings.publisher(for: .hasUserUnlockedOnboardingChecklist)
            .compactMap { $0 }
            .assign(to: \.hasUserUnlockedOnboardingChecklist, on: self)
            .store(in: &cancellables)

        userSettings.publisher(for: .m2wDidFinishOnce)
            .compactMap { $0 }
            .assign(to: \.hasFinishedM2WAtLeastOnce, on: self)
            .store(in: &cancellables)

        userSettings.publisher(for: .chromeImportDidFinishOnce)
            .compactMap { $0 }
            .assign(to: \.hasFinishedChromeImportAtLeastOnce, on: self)
            .store(in: &cancellables)

        userSettings
            .publisher(for: .hasSeenDWMExperience)
            .compactMap { $0 }
            .assign(to: \.hasSeenDWMExperience, on: self)
            .store(in: &cancellables)

        userSettings.settingsChangePublisher(key: .guidedOnboardingData)
            .sink { [weak self] in
                self?.setupChecklist()
            }
            .store(in: &cancellables)
    }

    private func setupDWMPublishers() {
        dwmOnboardingService.progressPublisher()
            .assign(to: \.dwmOnboardingProgress, on: self)
            .store(in: &cancellables)

        dwmOnboardingSettings.publisher(for: .hasConfirmedEmailFromOnboardingChecklist)
            .compactMap { $0 }
            .assign(to: \.hasConfirmedEmailFromOnboardingChecklist, on: self)
            .store(in: &cancellables)
    }
}
