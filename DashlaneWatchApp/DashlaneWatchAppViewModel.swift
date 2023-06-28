import Foundation
import WatchConnectivity

final class DashlaneWatchAppViewModel: ObservableObject {
    
    @Published var applicationContext: WatchApplicationContext
    private let watchConnectivity: WatchAppConnectivity
    
    init() {
        watchConnectivity = .init()
        if let data = try? Data(contentsOf: URL.contextUrl()),
           let context = try? JSONDecoder().decode(WatchApplicationContext.self, from: data) {
            applicationContext = context
        } else {
            applicationContext = .init()
        }
        
        watchConnectivity
            .$context
            .compactMap { $0 }
            .assign(to: &$applicationContext)
    }
}
