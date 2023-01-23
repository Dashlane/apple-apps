import SwiftUI

extension Text {
    
            @ViewBuilder
    public func bold(_ isBold: Bool) -> some View {
        if isBold {
            self.bold()
        } else {
            self
        }
    }
}
