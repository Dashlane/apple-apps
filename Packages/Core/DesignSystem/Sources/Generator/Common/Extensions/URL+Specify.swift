import Foundation

extension URL {
  static func specifyRepository(named repositoryName: String) -> URL {
    URL(string: "_\(repositoryName)/design-tokens")!
  }
}
