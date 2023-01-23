import WatchKit

final public class ExtensionDelegate: NSObject, WKExtensionDelegate {

    public func applicationDidFinishLaunching() {
            }

    public func applicationDidBecomeActive() {
            }

    public func applicationWillResignActive() {
                    }

    public func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
                for task in backgroundTasks {
                        switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
