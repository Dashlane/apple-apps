import Foundation
import SwiftUI

extension DS: ShapeStyle {
  public func resolve(in environment: EnvironmentValues) -> Never {
    fatalError()
  }
}

extension ShapeStyle where Self == DS {
  public static var ds: DS.Type {
    return DS.self
  }
}
