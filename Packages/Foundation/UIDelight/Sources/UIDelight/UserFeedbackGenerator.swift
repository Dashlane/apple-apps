import Foundation
import UIKit

public protocol SelectionFeedbackGenerator {
  func prepare()
  func selectionChanged()
}

public protocol ImpactFeedbackGenerator {
  func impactOccurred()
  func impactOccurred(intensity: CGFloat)
}

public protocol NotificationFeedbackGenerator {

}

struct NoOpFeedbackGenerator: SelectionFeedbackGenerator, ImpactFeedbackGenerator {
  func prepare() {}
  func selectionChanged() {}
  func impactOccurred() {}
  func impactOccurred(intensity: CGFloat) {}
}

public struct UserFeedbackGenerator {
  public static func makeSelectionFeedbackGenerator() -> SelectionFeedbackGenerator {
    #if os(iOS)
      return UISelectionFeedbackGenerator()
    #else
      return NoOpFeedbackGenerator()
    #endif
  }

  public static func makeImpactGenerator() -> ImpactFeedbackGenerator {
    #if os(iOS)
      return UIImpactFeedbackGenerator()
    #else
      return NoOpFeedbackGenerator()
    #endif
  }
}

#if os(iOS)
  extension UISelectionFeedbackGenerator: SelectionFeedbackGenerator {}
  extension UIImpactFeedbackGenerator: ImpactFeedbackGenerator {}
#endif
