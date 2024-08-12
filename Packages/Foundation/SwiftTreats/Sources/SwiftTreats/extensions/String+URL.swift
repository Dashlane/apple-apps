import Foundation

extension String {
  public var openableURL: URL? {
    guard let url = URL(string: self) else {
      return nil
    }

    if url.scheme != nil {
      return url
    } else {
      return URL(string: "_" + url.absoluteString)
    }
  }
}
