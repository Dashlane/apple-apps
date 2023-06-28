import SwiftUI

@main
struct DashlaneWatchApp: App {
    @StateObject var viewModel: DashlaneWatchAppViewModel
    
    init() {
        self._viewModel = .init(wrappedValue: .init())
    }
    
    var body: some Scene {
        WindowGroup {
            WatchTokenList(context: viewModel.applicationContext)
        }
    }
}
