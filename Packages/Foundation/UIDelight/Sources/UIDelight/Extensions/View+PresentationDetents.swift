import Foundation
import SwiftUI

#if os(iOS)

public extension View {
        @ViewBuilder
    func bottomSheet(_ detents: Set<BottomSheetDetents> = [.medium, .large]) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents(detents.detents)
        } else {
            self
        }
    }
    
}

public enum BottomSheetDetents: Hashable {
    case medium
    case large
    case fraction(CGFloat)

    @available(iOS 16, *)
    var detent: PresentationDetent {
        switch self {
        case .medium: return .medium
        case .large: return .large
        case let .fraction(fraction): return .fraction(fraction)
        }
    }

    public static func ==(lhs: BottomSheetDetents, rhs: BottomSheetDetents) -> Bool {
        switch (lhs, rhs) {
        case (.medium, .medium): return true
        case (.large, .large): return true
        case (let .fraction(lhs), let .fraction(rhs)): return rhs == lhs
        default: return false
        }
    }
}

@available(iOS 16, *)
public extension Collection where Element == BottomSheetDetents {
    var detents: Set<PresentationDetent> {
        Set(map({ $0.detent }))
    }
}

#endif
