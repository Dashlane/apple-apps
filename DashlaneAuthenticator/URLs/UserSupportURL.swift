import Foundation
import SwiftUI
import UIDelight

enum UserSupportURL: String {
    
    case dashlaneTwoStepsVerification = "_"
    case base = "_"
    case whatIsDashlane = "_"
    case protectAccountUsing2FA = "_"
    case useBiomtryOrPin = "_"
    case changePin = "_"
    case troubleshooting = "_"
    case helpCenter = "_"
    
    var url: URL {
        URL(string: self.rawValue)!
    }
}

extension View {
        func safariSheet(isPresented: Binding<Bool>,
                     _ supportURL: UserSupportURL) -> some View {
        self.safariSheet(isPresented: isPresented, url: supportURL.url)
    }
}

extension Link {
    init(title: String,
         supportURL: UserSupportURL,
         isPresented: Binding<Bool>? = nil) {
        self.init(title: title,
                  url: supportURL.url,
                  isPresented: isPresented)
    }
}
