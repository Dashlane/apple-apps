import SwiftUI

public extension View {
        @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func throwableTask(_ action: @MainActor @Sendable @escaping () async throws -> Void) -> some View {
        self.modifier(TaskViewModifier(action: action))
    }
}

struct TaskViewModifier: ViewModifier {
    @MainActor
    class TaskOwner: ObservableObject {
        var task: Task<Void, Error>? = nil
        
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


