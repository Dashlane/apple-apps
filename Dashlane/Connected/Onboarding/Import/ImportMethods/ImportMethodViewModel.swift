import Combine
import CoreTypes
import SwiftUI
import UserTrackingFoundation

enum ImportMethodCompletion {
  case back
  case skip
  case methodSelected(LegacyImportMethod)
}

struct ImportMethodSection: Identifiable {
  let id: String
  let items: [LegacyImportMethod]
  let header: String?

  init(section: (header: String?, methods: [LegacyImportMethod])) {
    self.id = UUID().uuidString
    self.items = section.methods
    self.header = section.header?.localizedUppercase
  }
}

protocol ImportMethodViewModelProtocol: ObservableObject {
  var sections: [ImportMethodSection] { get }
  var completion: (ImportMethodCompletion) -> Void { get }

  func logDisplay()
  func methodSelected(_ method: LegacyImportMethod)
  func back()
  func skip()
}

class ImportMethodViewModel: ImportMethodViewModelProtocol, SessionServicesInjecting {

  enum Action {
    case back
    case methodSelected(LegacyImportMethod)
  }

  let sections: [ImportMethodSection]
  let completion: (ImportMethodCompletion) -> Void

  private let activityReporter: ActivityReporterProtocol
  private let importService: ImportMethodServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  init(
    importService: ImportMethodServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    completion: @escaping (ImportMethodCompletion) -> Void
  ) {
    self.importService = importService
    self.activityReporter = activityReporter
    self.completion = completion

    sections = importService.methods
  }

  func logDisplay() {
    if case .firstPassword = importService.mode {
      activityReporter.reportPageShown(.homeAddItem)
    }
  }

  func back() {
    cancellables.forEach { $0.cancel() }
    completion(.back)
  }

  func skip() {
    cancellables.forEach { $0.cancel() }
    completion(.skip)
  }

  func methodSelected(_ method: LegacyImportMethod) {
    completion(.methodSelected(method))
  }
}
