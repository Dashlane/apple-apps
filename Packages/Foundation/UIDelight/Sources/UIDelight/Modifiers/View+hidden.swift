import SwiftUI

extension View {

            public func hidden(_ isHidden: Bool) -> Self? {
        if isHidden {
            return nil
        } else {
            return self
        }
    }
}
