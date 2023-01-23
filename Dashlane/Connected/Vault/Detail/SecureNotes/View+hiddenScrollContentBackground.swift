import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func hiddenScrollContentBackground () -> some View {
        if #available(iOS 16, *) {
                        #if !targetEnvironment(macCatalyst)
            self.scrollContentBackground(.hidden)
            #else
            self
            #endif
        } else {
            self
        }
    }
}
