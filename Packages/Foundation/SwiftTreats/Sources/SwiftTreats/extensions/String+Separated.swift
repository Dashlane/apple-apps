import Foundation

extension String {
  public func separated(by separator: String = " ", stride: Int = 3) -> String {
    return enumerated().map {
      $0.isMultiple(of: stride) && ($0 != 0) ? "\(separator)\($1)" : String($1)
    }.joined()
  }
}
