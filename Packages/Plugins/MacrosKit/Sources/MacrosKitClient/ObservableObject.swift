import Foundation
import MacrosKit
import SwiftUI

@ObservableObject
class MyModel {
  let fixedParam: String = ""
  var param1: Bool = false
  var param2: String?
  @ObservationIgnored
  var param3: String = "sd"

  var composed: String {
    return "hello"
  }
}
