import Foundation

enum AttachmentState: Equatable, Hashable {
  enum LoadingType {
    case upload
    case download
  }

  var isLoading: Bool {
    switch self {
    case .loading: return true
    default: return false
    }
  }

  case idle
  case loading(progress: Progress, type: LoadingType)
  case downloaded
}
