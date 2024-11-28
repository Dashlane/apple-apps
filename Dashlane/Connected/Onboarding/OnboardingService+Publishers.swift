import Combine
import Foundation

extension OnboardingService {
  func setupSubscribers() {
    vaultItemsStore
      .allItemsPublisher()
      .first { $0.count > 1 }
      .sink { [weak self] _ in
        self?.userSettings[.hasCreatedAtLeastOneItem] = true
      }
      .store(in: &cancellables)

    setupSettingsPublishers()
    setupDWMPublishers()

    let hasSkipPasswordOnboarding: AnyPublisher<Bool, Never> = userSettings.publisher(
      for: .hasSkippedPasswordOnboarding
    )
    .compactMap { $0 }
    .removeDuplicates()
    .prepend(false)
    .eraseToAnyPublisher()

    let hasAtLeastOnePassword = vaultItemsStore.$credentials
      .removeDuplicates()
      .map { $0.isEmpty == false }
      .filter { $0 == true }
      .prepend(false)
      .eraseToAnyPublisher()

    hasSkipPasswordOnboarding
      .combineLatest(hasAtLeastOnePassword) { (skipped, hasOnePassword) -> Bool in
        skipped || hasOnePassword
      }
      .receive(on: RunLoop.main)
      .assign(to: &$hasPassedPasswordOnboarding)

    autofillService.$activationStatus
      .removeDuplicates()
      .map { $0 == .enabled }
      .receive(on: RunLoop.main)
      .assign(to: &$isAutofillActivated)

    setupSettingsUpdatePublisher()
  }

  private func setupSettingsUpdatePublisher() {
    let hasSeenUnexpectedErrorPublisher: AnyPublisher<Bool, Never> =
      dwmOnboardingSettings.publisher(for: .hasSeenUnexpectedError).compactMap { $0 }
      .eraseToAnyPublisher()

    self.changePublisher = Publishers.MergeMany([
      $hasUserDismissedOnboardingChecklist.eraseToAnyPublisher(),
      $hasUserUnlockedOnboardingChecklist.eraseToAnyPublisher(),
      $hasFinishedM2WAtLeastOnce.eraseToAnyPublisher(),
      $hasFinishedChromeImportAtLeastOnce.eraseToAnyPublisher(),
      $hasSeenDWMExperience.eraseToAnyPublisher(),
      $hasPassedPasswordOnboarding.eraseToAnyPublisher(),
      $dwmOnboardingProgress.map { _ in true }.eraseToAnyPublisher(),
      $hasConfirmedEmailFromOnboardingChecklist.eraseToAnyPublisher(),
      hasSeenUnexpectedErrorPublisher,
      $isAutofillActivated.eraseToAnyPublisher(),
    ])
    .compactMap { $0 }
    .mapToVoid()
    .receive(on: RunLoop.main)
    .eraseToAnyPublisher()

    self.changePublisher?
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        guard let self else { return }
        self.remainingActions = self.actions.filter { self.completionState(for: $0) == .todo }
      }
      .store(in: &cancellables)

    Publishers.MergeMany([
      userSettings.settingsChangePublisher(key: .guidedOnboardingData).map { _ in true }
        .eraseToAnyPublisher(),
      $dwmOnboardingProgress.map { _ in true }.eraseToAnyPublisher(),
      $hasConfirmedEmailFromOnboardingChecklist.eraseToAnyPublisher(),
      hasSeenUnexpectedErrorPublisher,
    ])
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
