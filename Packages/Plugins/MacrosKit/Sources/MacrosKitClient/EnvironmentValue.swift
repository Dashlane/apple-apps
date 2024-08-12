import Foundation
import MacrosKit
import SwiftUI

extension EnvironmentValues {
  @EnvironmentValue
  var value: Bool = false

  @EnvironmentValue
  var value2: String?
}
