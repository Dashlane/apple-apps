import Foundation
import SwiftTreats
import SwiftUI

extension Image {
  public init(biometry: Biometry) {
    let systemName: String =
      switch biometry {
      case .touchId:
        "touchid"
      case .faceId:
        "faceid"
      case .opticId:
        "opticid"
      }

    self.init(systemName: systemName)
  }
}
