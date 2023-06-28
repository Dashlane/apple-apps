import Combine
import Foundation
import CoreSettings

public struct PinCodeAttempts {

        public var dates: [Date] {
        return userLockSettings[.pinCodeAttempts] ?? [Date]()
    }

        public var count: Int {
        return dates.count
    }

                public var tooManyAttempts: Bool {
        return count >= 3
    }

        public var datesPublisher: AnyPublisher<[Date], Never> {
        return changePublisher.map { _ in self.dates }.eraseToAnyPublisher()
    }

        public var countPublisher: AnyPublisher<Int, Never> {
        return changePublisher.map { _ in self.count }.eraseToAnyPublisher()
    }

        public var tooManyAttemptsPublisher: AnyPublisher<Bool, Never> {
        return changePublisher.map { _ in self.tooManyAttempts }.eraseToAnyPublisher()
    }

    private let userLockSettings: KeyedSettings<UserLockSettingsKey>

    private var changePublisher: AnyPublisher<Void, Never> {
        return userLockSettings.settingsChangePublisher(key: .pinCodeAttempts)
    }

            public init(internalStore: LocalSettingsStore) {
        self.userLockSettings = internalStore.keyed(by: UserLockSettingsKey.self)
    }

            public func addNewAttempt(date: Date = Date()) {
        var pinCodeAttempts = userLockSettings[.pinCodeAttempts] ?? [Date]()
        pinCodeAttempts.append(date)

        userLockSettings[.pinCodeAttempts] = pinCodeAttempts
    }

        public func removeAll() {
        userLockSettings[.pinCodeAttempts] = [Date]()
    }

}

extension PinCodeAttempts {

    public static var mock: Self {
        return .init(internalStore: .mock())
    }

}

extension PinCodeAttempts: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.dates == rhs.dates
    }

}
