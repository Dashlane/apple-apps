import Foundation
import SwiftUI

public struct Typography {
    
    static var largeHeader: SwiftUI.Font {
        return .custom(FontFamily.GTWalsheimPro.medium.name, fixedSize: 32)
    }
    
    static var title: SwiftUI.Font {
        return .custom(FontFamily.GTWalsheimPro.medium.name, fixedSize: 20)
    }
    
    static var smallHeader: SwiftUI.Font {
        return .system(size: 16, weight: .semibold)
    }

    static var body: SwiftUI.Font {
        return .system(size: 16, weight: .regular)
    }
    
    static var bodyMonospaced: SwiftUI.Font {
        return .body.monospaced()
    }
    
    static var caption: SwiftUI.Font {
        return .system(size: 12, weight: .medium)
    }
    
    static var caption2: SwiftUI.Font {
        return .system(size: 12, weight: .regular)
    }
}
