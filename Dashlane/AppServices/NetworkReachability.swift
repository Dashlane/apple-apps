import Foundation
import Network

class NetworkReachability {
    let queue = DispatchQueue(label: "Monitor")
    let monitor = NWPathMonitor()
    var interfaceType: NWInterface.InterfaceType?
    @Published
    var isConnected: Bool = false
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

        init(isConnected: Bool, interfaceType: NWInterface.InterfaceType? = .wifi) {
        self.isConnected = isConnected
        self.interfaceType = interfaceType
    }

}
