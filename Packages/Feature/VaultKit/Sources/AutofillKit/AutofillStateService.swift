import AuthenticationServices
import Combine
import CoreFeature
import CorePersonalData
import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

public class AutofillStateService: AutofillStateServiceProtocol {
  private typealias VaultPublisherOutput = (any Collection<Credential>, any Collection<Passkey>)

  let systemIdentityStoreUpdater: SystemIdentityStoreUpdater
  let queue = DispatchQueue(label: "AutofillServiceQueue", qos: .background)

  @Published
  public var activationStatus: AutofillActivationStatus = .disabled
  public var activationStatusPublisher: AnyPublisher<AutofillActivationStatus, Never> {
    $activationStatus.removeDuplicates().eraseToAnyPublisher()
  }
  var subscriptions: Set<AnyCancellable> = []
  let logger: Logger
  var refreshStatusTask: Task<Void, Never>?

  deinit {
    refreshStatusTask?.cancel()
    subscriptions.forEach { $0.cancel() }
  }

  public init(
    identityStore: IdentityStore = ASCredentialIdentityStore.shared,
    credentialsPublisher: some Publisher<some Collection<Credential>, Never>,
    passkeysPublisher: some Publisher<some Collection<Passkey>, Never>,
    refreshStatusTrigger: AnyPublisher<Notification, Never>? = NotificationCenter.default
      .willEnterForegroundNotificationPublisher()?.eraseToAnyPublisher(),
    cryptoEngine: CryptoEngine,
    vaultStateService: VaultStateServiceProtocol,
    logger: Logger, snapshotFolderURL: URL
  ) {

    let snapshotPersistor = FileSnapshotPersistor(
      folderURL: snapshotFolderURL,
      cryptoEngine: cryptoEngine,
      logger: logger)
    self.systemIdentityStoreUpdater = SystemIdentityStoreUpdater(
      identityStore: identityStore,
      snapshotPersistor: snapshotPersistor)
    self.logger = logger

    refreshStatusTask = Task { @MainActor [weak self] in
      self?.activationStatus = await identityStore.status()

      guard
        let statusSequence = refreshStatusTrigger?
          .values
          .map({ _ in await identityStore.status() })
      else {
        return
      }

      for await status in statusSequence where status != self?.activationStatus {
        self?.activationStatus = status
      }
    }

    $activationStatus
      .filter { status in
        status == .enabled
      }
      .combineLatest(vaultStateService.vaultStatePublisher()) { _, vaultState in
        vaultState
      }
      .flatMap { vaultState in
        guard vaultState != .frozen else {
          return Just<VaultPublisherOutput>(([], [])).eraseToAnyPublisher()
        }

        return credentialsPublisher.combineLatest(passkeysPublisher) {
          credentials, passkeys -> VaultPublisherOutput in
          return (credentials, passkeys)
        }.eraseToAnyPublisher()
      }
      .debounce(for: .milliseconds(500), scheduler: queue)
      .map { (credentials, passkeys) in
        return SystemIdentityStoreUpdater.UpdateRequest(
          credentials: credentials, passkeys: passkeys)
      }
      .sink { [weak self] request in
        self?.update(with: request)
      }
      .store(in: &subscriptions)
  }

  public func unload(shouldClear: Bool) async {
    refreshStatusTask?.cancel()
    subscriptions.forEach { $0.cancel() }

    if shouldClear {
      await clear()
    }
  }

  private func update(with request: SystemIdentityStoreUpdater.UpdateRequest) {
    Task {
      do {
        try await systemIdentityStoreUpdater.update(with: request)
      } catch {
        logger.error("Fail to update identity store", error: error)
      }
    }
  }

  private func clear() async {
    do {
      try await systemIdentityStoreUpdater.clear()
    } catch {
      logger.error("Fail to clear store on unload", error: error)
    }
  }
}

extension AutofillStateService {
  public func save(_ credential: Credential, oldCredential: Credential?) async {
    do {
      try await systemIdentityStoreUpdater.update(with: .init(new: credential, old: oldCredential))
    } catch {
      logger.error("Fail to update credential \(credential.id)", error: error)
    }
  }

  public func save(_ passkey: Passkey, oldPasskey: Passkey?) async {
    do {
      try await systemIdentityStoreUpdater.update(with: .init(new: passkey, old: oldPasskey))
    } catch {
      logger.error("Fail to update passkey \(passkey.id)", error: error)
    }
  }
}

extension AutofillStateService {
  public static var fakeService: AutofillStateService {
    .init(
      credentialsPublisher: Just<[Credential]>([]).eraseToAnyPublisher(),
      passkeysPublisher: Just<[Passkey]>([]).eraseToAnyPublisher(),
      cryptoEngine: .mock(),
      vaultStateService: .mock(),
      logger: .mock,
      snapshotFolderURL: URL.documentsDirectory)
  }
}
