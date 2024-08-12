import Foundation

#if canImport(UIKit)
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

struct NoOpFeedbackGenerator: SelectionFeedbackGenerator, ImpactFeedbackGenerator {
  func prepare() {}
  func selectionChanged() {}
  func impactOccurred() {}
  func impactOccurred(intensity: CGFloat) {}
}

public struct UserFeedbackGenerator {
  public static func makeSelectionFeedbackGenerator() -> SelectionFeedbackGenerator {
    #if canImport(UIKit)
      return UISelectionFeedbackGenerator()
    #else
      return NoOpFeedbackGenerator()
    #endif
  }

  public static func makeImpactGenerator() -> ImpactFeedbackGenerator {
    #if canImport(UIKit)
      return UIImpactFeedbackGenerator()
    #else
      return NoOpFeedbackGenerator()
    #endif
  }
}

#if canImport(UIKit)
  extension UISelectionFeedbackGenerator: SelectionFeedbackGenerator {}
  extension UIImpactFeedbackGenerator: ImpactFeedbackGenerator {}
#endif
