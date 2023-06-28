import Foundation
import DashTypes

public struct MemoryPressureLogger {
    private let trackingQueue = DispatchQueue.init(label: "memory tracker")

    public init(webService: LegacyWebService,
                origin: KibanaLogger.Origin) {
        let exceptionLoggerService = KibanaLogger(webService: webService,
                                                  outputLevel: .info,
                                                  origin: origin)
                let source = DispatchSource.makeMemoryPressureSource(eventMask: [.critical, .warning], queue: nil)
        trackingQueue.async {
            source.setEventHandler {
                let event: DispatchSource.MemoryPressureEvent  = source.mask
                switch event {
                case DispatchSource.MemoryPressureEvent.warning,
                     DispatchSource.MemoryPressureEvent.critical:
                    exceptionLoggerService.log(event)
                default:
                    break
                }

            }
            source.resume()
        }
    }
}

private extension Logger {
    nonmutating func log(_ pressure: DispatchSource.MemoryPressureEvent) {
        let memoryUsage = retrieveUsedMemory().map { "Used: \($0)MB - Event: \(pressure.title)" }  ?? ""
        warning("Memory pressure | \(memoryUsage)")
    }
}

private func retrieveUsedMemory() -> Float? {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
    let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
        return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
            return task_info(
                mach_task_self_,
                task_flavor_t(MACH_TASK_BASIC_INFO),
                machPtr,
                &count
            )
        }
    }
    guard kerr == KERN_SUCCESS else {
        return nil
    }
    return Float(info.resident_size) / (1024 * 1024)
}

private extension DispatchSource.MemoryPressureEvent {
    var title: String {
        switch self {
        case DispatchSource.MemoryPressureEvent.normal:
            return "normal"
        case DispatchSource.MemoryPressureEvent.warning:
            return "warning"
        case DispatchSource.MemoryPressureEvent.critical:
            return "critical"
        default:
            return "unknown"
        }
    }
}
