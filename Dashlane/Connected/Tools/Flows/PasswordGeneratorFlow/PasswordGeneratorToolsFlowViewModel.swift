import Combine
import CorePersonalData
import DashTypes
import Foundation
import SwiftUI
import VaultKit

@MainActor
class PasswordGeneratorToolsFlowViewModel: ObservableObject, SessionServicesInjecting {

  enum Step {
    case root
    case history
  }

  @Published
  var steps: [Step] = [.root]

  let deepLinkingService: DeepLinkingServiceProtocol
  let pasteboardService: PasteboardServiceProtocol
  let passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.ThirdFactory
  let passwordGeneratorHistoryViewModelFactory: PasswordGeneratorHistoryViewModel.Factory

  let deepLinkShowPasswordHistoryPublisher: AnyPublisher<Void, Never>

  init(
    deepLinkingService: DeepLinkingServiceProtocol,
    pasteboardService: PasteboardServiceProtocol,
    passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.ThirdFactory,
    passwordGeneratorHistoryViewModelFactory: PasswordGeneratorHistoryViewModel.Factory
  ) {
    self.deepLinkingService = deepLinkingService
    self.pasteboardService = pasteboardService
    self.passwordGeneratorViewModelFactory = passwordGeneratorViewModelFactory
    self.passwordGeneratorHistoryViewModelFactory = passwordGeneratorHistoryViewModelFactory

    deepLinkShowPasswordHistoryPublisher = deepLinkingService.deepLinkPublisher
      .filter({ deepLink -> Bool in
        guard case let .tool(component, _) = deepLink else {
          return false
        }

        guard case let .otherTool(other) = component else {
          return false
        }

        switch other {
        case .history:
          return true
        default:
          return false
        }
      })
      .mapToVoid()

  }

  func makePasswordGeneratorViewModel() -> PasswordGeneratorViewModel {

    let action: (PasswordGeneratorMode.StandaloneAction) -> Void = { [weak self] action in
      guard let self else { return }
      switch action {
      case .showHistory:
        self.steps.append(.history)
      case let .createCredential(password):
        self.deepLinkingService.handleLink(.prefilledCredential(password: password))
      }
    }

    return passwordGeneratorViewModelFactory.make(
      mode: .standalone(action), copyAction: { password in self.pasteboardService.set(password) })
  }

  func showHistory() {
    self.steps.append(.history)
  }
}

extension PasswordGeneratorToolsFlowViewModel {
  static var mock: PasswordGeneratorToolsFlowViewModel {
    .init(
      deepLinkingService: DeepLinkingService.fakeService,
      pasteboardService: PasteboardService.mock(),
      passwordGeneratorViewModelFactory: .init({ _, _ in .mock }),
      passwordGeneratorHistoryViewModelFactory: .init({ .mock() }))
  }
}
