import Combine
import Foundation
import Network

protocol NetworkReachabilityProtocol {
  var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
  var isConnected: Bool { get }
}

class NetworkReachability: NetworkReachabilityProtocol {

  let queue = DispatchQueue(label: "Monitor")
  let monitor = NWPathMonitor()
  var interfaceType: NWInterface.InterfaceType?
  @Published
  var isConnected: Bool = false

  var isConnectedPublisher: AnyPublisher<Bool, Never> {
    $isConnected.eraseToAnyPublisher()
  }

  init() {
    monitor.pathUpdateHandler = { path in
      if path.usesInterfaceType(.wifi) {
        self.interfaceType = .wifi
      } else if path.usesInterfaceType(.cellular) {
        self.interfaceType = .cellular
      }

      self.isConnected = path.status == .satisfied
    }
    monitor.start(queue: queue)
  }
}

class NetworkReachabilityMock: NetworkReachabilityProtocol {

  @Published
  var isConnected: Bool

  var isConnectedPublisher: AnyPublisher<Bool, Never> {
    Just(isConnected).eraseToAnyPublisher()
  }

  init(isConnected: Bool) {
    self.isConnected = isConnected
  }
}
extension NetworkReachabilityProtocol where Self == NetworkReachabilityMock {
  static func mock(isConnected: Bool = true) -> NetworkReachabilityProtocol {
    NetworkReachabilityMock(isConnected: isConnected)
  }
}
