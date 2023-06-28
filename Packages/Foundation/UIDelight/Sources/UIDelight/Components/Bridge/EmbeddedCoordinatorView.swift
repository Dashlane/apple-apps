#if canImport(UIKit)

import Foundation
import SwiftUI

protocol EmbeddedCoordinator {
    associatedtype Root: View
    func start() -> Root
}

struct EmbeddedCoordinatorView<Coordinator: EmbeddedCoordinator>: View {
    @StateObject
    private var store = CoordinatorStore<Coordinator>()

    let coordinator: (NavigationViewProxy) -> Coordinator

    var body: some View {
        NavigationViewReader { proxy in
            let coordinator = coordinator(proxy)
            coordinator.start()
                .onAppear {
                    store.coordinator = coordinator
                }
        }
    }
}

private class CoordinatorStore<Coordinator: EmbeddedCoordinator>: ObservableObject {
    var coordinator: Coordinator?
}

#endif
