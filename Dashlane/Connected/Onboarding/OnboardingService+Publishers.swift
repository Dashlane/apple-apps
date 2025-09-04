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

    autofillService.activationStatusPublisher
      .removeDuplicates()
      .map { $0 == .enabled }
      .receive(on: RunLoop.main)
      .assign(to: &$isAutofillActivated)

    setupSettingsUpdatePublisher()
  }

  private func setupSettingsUpdatePublisher() {
    self.changePublisher = Publishers.MergeMany([
      $hasUserDismissedOnboardingChecklist.eraseToAnyPublisher(),
      $hasUserUnlockedOnboardingChecklist.eraseToAnyPublisher(),
      $hasFinishedM2WAtLeastOnce.eraseToAnyPublisher(),
      $hasFinishedChromeImportAtLeastOnce.eraseToAnyPublisher(),
      $hasPassedPasswordOnboarding.eraseToAnyPublisher(),
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
  }
}
