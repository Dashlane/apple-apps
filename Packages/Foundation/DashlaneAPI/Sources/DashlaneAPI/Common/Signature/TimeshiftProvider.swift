import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol TimeshiftProvider: Sendable {
  var timeshift: TimeInterval { get async throws }
}

protocol RemoteTimeProvider: Sendable {
  func remoteTime() async throws -> Int
}

actor TimeshiftProviderImpl: TimeshiftProvider {
  let remoteTimeProvider: RemoteTimeProvider
  private var currentTimeshiftRequestTask: Task<TimeInterval, Error>?
  private var currentTimeshift: TimeInterval?

  init(remoteTimeProvider: RemoteTimeProvider) {
    self.remoteTimeProvider = remoteTimeProvider
  }

  var timeshift: TimeInterval {
    get async throws {
      if let currentTimeshift {
        return currentTimeshift
      } else if let task = currentTimeshiftRequestTask {
        return try await task.value
      } else {
        let task = Task {
          defer {
            currentTimeshiftRequestTask = nil
          }
          let timeshift = try await retrieveTimeshift()
          currentTimeshift = timeshift
          return timeshift
        }
        currentTimeshiftRequestTask = task
        return try await task.value
      }
    }
  }

  private func retrieveTimeshift() async throws -> TimeInterval {
    let result = try await remoteTimeProvider.remoteTime()
    let timeshift = TimeInterval(result)

    guard let bootTime = TimeInterval.currentKernelBootTime() else {
      let now = Date()
      return now.timeIntervalSince(Date(timeIntervalSince1970: timeshift))
    }

    let intervalBetweenBootTimeAndServer: TimeInterval = timeshift - bootTime

    return intervalBetweenBootTimeAndServer
  }
}

extension TimeInterval {
  #if os(Linux)
    static func currentKernelBootTime() -> TimeInterval? {
      #warning("currentKernelBootTime is not available on Linux yet.")
      return nil
    }
  #else
    static func currentKernelBootTime() -> TimeInterval? {
      var mangementInformationBase = [CTL_KERN, KERN_BOOTTIME]
      var bootTime = timeval()
      var bootTimeSize: Int = MemoryLayout<timeval>.size
      guard
        sysctl(
          &mangementInformationBase, UInt32(mangementInformationBase.count), &bootTime,
          &bootTimeSize, nil, 0) != -1
      else {
        assertionFailure("sysctl call failed")
        return nil
      }
      return Date().timeIntervalSince1970
        - (TimeInterval(bootTime.tv_sec) + TimeInterval(bootTime.tv_usec) / 1_000_000.0)
    }
  #endif
}

public struct TimeshiftProviderMock: TimeshiftProvider {
  public var timeshift: TimeInterval = 0
}

extension TimeshiftProvider where Self == TimeshiftProviderMock {
  public static func mock(timeshift: TimeInterval = 0) -> TimeshiftProviderMock {
    TimeshiftProviderMock(timeshift: timeshift)
  }
}
