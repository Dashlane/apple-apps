import Foundation
import SwiftUI

extension View {
    
    func modal(title: String,
               message: String,
               actionTitle: String,
               cancel: @escaping () -> Void,
               action: @escaping () -> Void,
               shouldBePresented: Binding<Bool>) -> some View {
        ZStack {
            
            self
            if shouldBePresented.wrappedValue {
                ModalAlertView(title: title,
                               message: message,
                               actionTitle: actionTitle,
                               cancel: cancel,
                               action: action,
                               isVisible: shouldBePresented)
                    .padding()
            }
        }
    }
}
