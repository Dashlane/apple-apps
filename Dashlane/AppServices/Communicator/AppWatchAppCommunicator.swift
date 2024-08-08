import Combine
import CorePersonalData
import Foundation
import VaultKit
import WatchConnectivity

public class AppWatchAppCommunicator: NSObject {
  private let vaultItemsStore: VaultItemsStore
  private var session: WCSession?
  private let applicationContext = WatchApplicationContext()
  private var cancellable: AnyCancellable?

  init(vaultItemsStore: VaultItemsStore) {
    self.vaultItemsStore = vaultItemsStore
    super.init()
    setup()
  }

  private func setup() {
    if session == nil && WCSession.isSupported() {
      session = WCSession.default
      session!.delegate = self
      session!.activate()
    }
    cancellable = vaultItemsStore.$credentials.sink { [weak self] credentials in
      self?.updateTokens(for: credentials)
    }
  }

  func updateTokens(for credentials: [Credential]) {
    self.applicationContext.tokens = credentials.compactMap { credential in
      guard let otpUrl = credential.otpURL else {
        return nil
      }
      let title = credential.displayTitle
      return WatchApplicationContext.Token(url: otpUrl, title: title)
    }
    self.sendContext()
  }

  func unload() {
    removeTokens()
  }

  private func removeTokens() {
    applicationContext.tokens = []
    sendContext()
  }

  private func sendContext() {
    do {
      let dict = try applicationContext.toDict()
      if session?.activationState == .activated {
        try session?.updateApplicationContext(dict)
      }
    } catch {}
  }
}

extension AppWatchAppCommunicator: WCSessionDelegate {
  public func session(
    _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    guard error == nil else {
      return
    }
    self.sendContext()
  }

  public func sessionDidBecomeInactive(_ session: WCSession) {}

  public func sessionDidDeactivate(_ session: WCSession) {}

  public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    guard let feedback = try? WatchFeedbackMessage.fromDict(message),
      feedback.action == .refreshContext
    else {
      return
    }
    sendContext()
  }
}
