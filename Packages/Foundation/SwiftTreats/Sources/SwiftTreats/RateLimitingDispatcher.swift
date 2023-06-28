import Foundation

public class RateLimitingDispatcher {
    public typealias Completion = () -> Void
    let executionQueue: DispatchQueue
    let executionLock: Locking
    @Atomic
    var executionPending: Bool = false

    let closure: (Completion?) -> Void
    let delayBetweenExecutions: TimeInterval

    public init(delayBetweenExecutions: TimeInterval = 0.0,
                queue: DispatchQueue,
                lock: Locking = Lock(),
                closure: @escaping (Completion?) -> Void) {
        self.closure = closure
        self.delayBetweenExecutions = delayBetweenExecutions
        self.executionLock = lock
        executionQueue = queue
    }

    public func dispatch() {
        do {
            try executionLock.lock()
            performDispatch()
        } catch LockError.alreadyLocked(isCurrentInstanceOwner: true) {
            executionPending = true
        } catch LockError.alreadyLocked(isCurrentInstanceOwner: false) {
                        executionQueue.asyncAfter(deadline: .now() + self.delayBetweenExecutions, execute: dispatch)
        } catch {

        }
    }

    private func performDispatch() {
        self.executionQueue.async { [weak self] in
            guard let self = self else { return }
            self.closure {
                if self.delayBetweenExecutions > 0 {
                    self.executionQueue.asyncAfter(wallDeadline: .now() + self.delayBetweenExecutions, execute: self.terminateDispatch)
                } else {
                    self.terminateDispatch()
                }
            }
        }
    }

    private func terminateDispatch() {
        if executionPending {
            executionPending = false
            performDispatch()
        } else {
            executionLock.unlock()
        }
    }
}
