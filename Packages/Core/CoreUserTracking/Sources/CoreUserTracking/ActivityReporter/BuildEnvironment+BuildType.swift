import DashTypes
import Foundation
import SwiftTreats

extension BuildEnvironment {
  var buildType: Definition.BuildType {
    if isQA {
      return .qa
    } else if isNightly {
      return .nightly
    } else if self == .debug {
      return .dev
    } else {
      return .production
    }
  }
}
