import Combine
import Foundation

extension Publisher where Failure == Never {
  public func assign<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root
  ) -> AnyCancellable {
    sink { [weak root] in
      root?[keyPath: keyPath] = $0
    }
  }
}
