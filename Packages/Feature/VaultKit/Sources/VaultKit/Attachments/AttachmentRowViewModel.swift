import Combine
import Foundation

public enum AttachmentRowAction {
  case rename
  case delete
  case preview
  case download
}

class AttachmentRowViewModel: ObservableObject {
  let id: String
  @Published
  var name: String
  let creationDate: String
  let fileSize: String
  @Published
  var state: AttachmentState = .idle
  let userAction: ((AttachmentRowAction) -> Void)
  @Published var progress: Double?

  private let fileDateFormat: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    return dateFormatter
  }()

  private let fileSizeFormatter: ByteCountFormatter = {
    let byteFormatter = ByteCountFormatter()
    byteFormatter.countStyle = .memory
    return byteFormatter
  }()

  init(
    id: String,
    name: String,
    fileNamePublisher: AnyPublisher<String, Never>,
    creationDate: UInt64,
    fileSize: Int,
    state: AnyPublisher<AttachmentState, Never>,
    userAction: @escaping (AttachmentRowAction) -> Void
  ) {
    self.id = id
    self.name = name
    self.creationDate = fileDateFormat.string(
      from: Date(timeIntervalSince1970: Double(creationDate)))
    self.fileSize = fileSizeFormatter.string(fromByteCount: Int64(fileSize))
    self.userAction = userAction
    state.assign(to: &$state)
    fileNamePublisher.assign(to: &$name)
    $state.map { state -> AnyPublisher<Double?, Never> in
      if case let .loading(progress, _) = state {
        return
          progress
          .publisher(for: \.fractionCompleted)
          .map { $0 as Double? }
          .eraseToAnyPublisher()
      } else {
        return Just<Double?>(nil).eraseToAnyPublisher()
      }
    }
    .switchToLatest()
    .receive(on: DispatchQueue.main)
    .assign(to: &$progress)
  }

  static var mock: AttachmentRowViewModel {
    AttachmentRowViewModel(
      id: "1", name: "filename", fileNamePublisher: Just("filename").eraseToAnyPublisher(),
      creationDate: UInt64(), fileSize: 123, state: Just(.idle).eraseToAnyPublisher(),
      userAction: { _ in })
  }
}
