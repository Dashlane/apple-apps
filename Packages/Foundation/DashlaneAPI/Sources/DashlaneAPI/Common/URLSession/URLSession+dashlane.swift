import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLSession {
  public static func dashlane() -> URLSession {
    URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)
  }
}
