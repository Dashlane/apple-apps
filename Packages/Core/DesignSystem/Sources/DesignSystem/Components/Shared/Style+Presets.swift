import Foundation

extension Style {
  public static var error: Self { .init(mood: .danger, intensity: .catchy, priority: .high) }
  public static var positive: Self { .init(mood: .positive, intensity: .catchy, priority: .high) }
  public static var warning: Self { .init(mood: .warning, intensity: .catchy, priority: .high) }
}
