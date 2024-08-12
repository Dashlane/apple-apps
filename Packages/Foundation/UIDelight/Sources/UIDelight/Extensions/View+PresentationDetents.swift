import Foundation
import SwiftUI

extension View {
  @ViewBuilder
  public func bottomSheet(_ detents: Set<BottomSheetDetents> = [.medium, .large]) -> some View {
    self.presentationDetents(detents.detents)
  }

}

public enum BottomSheetDetents: Hashable {
  case medium
  case large
  case fraction(CGFloat)

  var detent: PresentationDetent {
    switch self {
    case .medium: return .medium
    case .large: return .large
    case let .fraction(fraction): return .fraction(fraction)
    }
  }

  public static func == (lhs: BottomSheetDetents, rhs: BottomSheetDetents) -> Bool {
    switch (lhs, rhs) {
    case (.medium, .medium): return true
    case (.large, .large): return true
    case (let .fraction(lhs), let .fraction(rhs)): return rhs == lhs
    default: return false
    }
  }
}

extension Collection where Element == BottomSheetDetents {
  public var detents: Set<PresentationDetent> {
    Set(map({ $0.detent }))
  }
}
