import Combine

enum M2WFlowStep {
  case start
  case connect

  enum Origin: String {
    case accountCreation
    case onboardingChecklist
    case newDeviceConnector
    case deepLink

    init(string: String?) {
      switch string {
      case "onboardingChecklist":
        self = .onboardingChecklist
      case "tools":
        self = .newDeviceConnector
      default:
        self = .deepLink
      }
    }
  }

  init(origin: Origin) {
    switch origin {
    case .accountCreation, .deepLink:
      self = .start
    case .onboardingChecklist, .newDeviceConnector:
      self = .connect
    }
  }
}

enum M2WDismissAction {
  case success
  case canceled
}

class M2WFlowViewModel: ObservableObject {

  @Published
  var steps: [M2WFlowStep]
  var dismissPublisher: AnyPublisher<M2WDismissAction, Never> {
    dismissSubject.eraseToAnyPublisher()
  }

  @Published
  var showAlert: Bool = false

  private let dismissSubject: PassthroughSubject<M2WDismissAction, Never> = .init()

  init(initialStep: M2WFlowStep = .start) {
    self.steps = [initialStep]
  }

  func handleStartViewAction(_ action: M2WStartView.Action) {
    switch action {
    case .didTapSkip:
      dismissSubject.send(.canceled)
    case .didTapConnect:
      steps.append(.connect)
    }
  }

  func handleConnectViewAction(_ action: M2WConnectView.Action) {
    switch action {
    case .didTapCancel:
      dismissSubject.send(.canceled)
    case .didTapDone:
      showAlert = true
    }
  }

  func handleAlertYesAction() {
    dismissSubject.send(.success)
  }
}
