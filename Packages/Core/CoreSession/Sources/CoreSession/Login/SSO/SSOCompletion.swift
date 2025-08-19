import Foundation

public enum SSOCompletion: Sendable {
  case completed(SSOCallbackInfos)
  case cancel
}
