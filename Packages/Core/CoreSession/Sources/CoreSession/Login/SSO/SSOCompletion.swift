import Foundation

public enum SSOCompletion {
  case completed(SSOCallbackInfos)
  case cancel
}
