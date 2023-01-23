import Foundation
#if os(iOS)
import UIKit
#endif

public protocol SelectionFeedbackGenerator {
    func prepare()
    func selectionChanged()
}

public protocol ImpactFeedbackGenerator {
    func impactOccurred()
    func impactOccurred(intensity: CGFloat)
}

public struct UserFeedbackGenerator {
    public static func makeSelectionFeedbackGenerator() ->  SelectionFeedbackGenerator? {
        #if os(iOS)
        return UISelectionFeedbackGenerator()
        #else
        return nil
        #endif
    }
    
    public static func makeImpactGenerator() -> ImpactFeedbackGenerator? {
        #if os(iOS)
        return UIImpactFeedbackGenerator()
        #else
        return nil
        #endif
    }
}


#if os(iOS)
extension UISelectionFeedbackGenerator: SelectionFeedbackGenerator { }
extension UIImpactFeedbackGenerator: ImpactFeedbackGenerator { }
#endif
