import Foundation

extension Sequence where Iterator.Element == URLQueryItem {
  public subscript(name: String) -> String? {
    return self.first { $0.name == name }?.value
  }
}
