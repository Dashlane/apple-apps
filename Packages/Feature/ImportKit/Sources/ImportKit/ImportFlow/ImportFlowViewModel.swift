import Combine
import UniformTypeIdentifiers

public enum ImportFlowKind {
  case dash
  case keychain
  case chrome
  case lastpass
}

public enum ImportFlowStep {

  fileprivate var shouldBePopped: Bool {
    switch self {
    case .error, .list:
      return true
    default:
      return false
    }
  }

  case intro(ImportInformationViewModel)
  case instructions(ImportInformationViewModel)
  case `extension`(ImportInformationViewModel)
  case list(ImportViewModel)
  case error(ImportViewModel)
}

public enum ImportDismissAction {
  case popToRootView
  case dismiss
}

@MainActor
public protocol ImportFlowViewModel: ObservableObject {

  associatedtype AnyImportViewModel: ImportViewModel, ObservableObject

  var kind: ImportFlowKind { get }
  var steps: [ImportFlowStep] { get set }
  var dismissPublisher: AnyPublisher<ImportDismissAction, Never> { get }
  var showPasswordView: Bool { get set }
  var isDroppingFileEnabled: Bool { get }
  var isLoading: Bool { get set }
  var fileData: Data? { get set }

  func handleIntroAction(_ action: ImportInformationView.Action)
  func handleInstructionsAction(_ action: ImportInformationView.Action)
  func handleExtensionAction(_ action: ImportInformationView.Action)
  func makeImportPasswordViewModel() -> DashImportViewModel
  func handlePasswordAction(_ action: DashImportPasswordView.Action)
  func handleListAction(_ action: ImportListView<AnyImportViewModel>.Action)
  func handleErrorAction(_ action: ImportErrorView.Action)
}

extension ImportFlowViewModel {

  public var isDroppingFileEnabled: Bool { false }

  public func handleInstructionsAction(_ action: ImportInformationView.Action) {
    assertionFailure("Inadmissible action for this kind (\(kind)) of import flow")
  }

  public func handleExtensionAction(_ action: ImportInformationView.Action) {
    assertionFailure("Inadmissible action for this kind (\(kind)) of import flow")
  }

  public func makeImportPasswordViewModel() -> DashImportViewModel {
    fatalError("Inadmissible action for this kind (\(kind)) of import flow")
  }

  public func handlePasswordAction(_ action: DashImportPasswordView.Action) {
    assertionFailure("Inadmissible action for this kind (\(kind)) of import flow")
  }

  public func handleListAction(_ action: ImportListView<ChromeImportViewModel>.Action) {
    assertionFailure("Inadmissible action for this kind (\(kind)) of import flow")
  }

  public func handleErrorAction(_ action: ImportErrorView.Action) {
    assertionFailure("Inadmissible action for this kind (\(kind)) of import flow")
  }

  func removeLastViewFromStackIfShouldBePopped() {
    if steps.last?.shouldBePopped == true {
      _ = steps.popLast()
    }
  }

}

extension ImportFlowKind {

  public var contentTypes: [UTType] {
    switch self {
    case .dash:
      guard let secureArchiveType = UTType("com.dashlane.document.securearchive") else {
        if !ProcessInfo.isTesting {
          assertionFailure("Couldn't instantiate secure archive custom type")
        }
        return []
      }
      return [secureArchiveType]
    case .keychain, .lastpass:
      return [.commaSeparatedText]
    case .chrome:
      return []
    }
  }

}
