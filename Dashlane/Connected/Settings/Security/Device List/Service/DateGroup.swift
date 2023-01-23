import Foundation

enum DateGroup: Hashable, CaseIterable, Identifiable, Equatable, Comparable {
    case last24Hours
    case lastMonth
    case lastYear
    case older

    var id: Int {
        return hashValue
    }

    init(date: Date) {
        let now = Date()
        let calendar = Calendar.current
        guard let last24Hours = calendar.date(byAdding: DateComponents(day: -1), to: now),
            let lastMonth = calendar.date(byAdding: DateComponents(month: -1), to: now),
            let lastYear = calendar.date(byAdding: DateComponents(year: -1), to: now) else {
                self = .older
                return
        }

        switch date {
            case let date where date > last24Hours:
                self = .last24Hours
            case let date where date > lastMonth:
                self = .lastMonth
            case let date where date > lastYear:
                self = .lastYear
            default:
                self = .older
        }
    }
}
