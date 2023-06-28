import SwiftUI

struct TaskViewModifier: ViewModifier {
    @MainActor
    class TaskOwner: ObservableObject {
        var task: Task<Void, Error>?

        deinit {
            task?.cancel()
        }

        func execute(_ action: @MainActor @Sendable @escaping () async throws -> Void) {
            task = Task(priority: .userInitiated) {
                try await action()
            }
        }
    }

    @StateObject
    var taskOwner: TaskOwner

    let action: @MainActor @Sendable () async throws -> Void

    init(action: @escaping @MainActor @Sendable () async throws -> Void) {
        self._taskOwner = .init(wrappedValue: TaskOwner())
        self.action = action
    }

    public func body(content: Content) -> some View {
        content.onAppear {
            taskOwner.execute(action)
        }
    }
}
