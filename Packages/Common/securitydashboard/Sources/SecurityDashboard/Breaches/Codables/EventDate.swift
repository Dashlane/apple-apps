import Foundation

public struct EventDate {
		public enum Precision {
		case year
		case month
		case day
	}

		public let precision: Precision

		public let value: String

		public let dateValue: Date

	public enum DateError: Error {
		case wrongDateFormat
	}

	public init?(withValue value: String) {

		self.value = value

										let components = value.split(separator: "-")

		switch components.count {
		case 1:
            guard let year = Int(components[0]),
                let date = DateComponents(calendar: .current, year: year).date else { return nil }
            self.dateValue = date
			self.precision = .year
		case 2:
            guard let year = Int(components[0]),
                let month = Int(components[1]),
                let date = DateComponents(calendar: .current, year: year, month: month).date else { return nil }
            self.dateValue = date
			self.precision = .month
		case 3:
            guard let year = Int(components[0]),
                let month = Int(components[1]),
                let day = Int(components[2]),
                let date = DateComponents(calendar: .current, year: year, month: month, day: day).date else { return nil }
            self.dateValue = date
			self.precision = .day
		default:
			return nil
		}
	}

                    public func posterior(to date: Date) -> Bool {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: self.dateValue)
        let month = calendar.component(.month, from: self.dateValue)

        let dateYear = calendar.component(.year, from: date)
        let dateMonth = calendar.component(.month, from: date)

        switch precision {
        case .year:
            return year >= dateYear
        case .month:
            return year >= dateYear
                && month >= dateMonth
        case .day:
            return dateValue > date
        }
    }
}

extension EventDate: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let stringValue = try container.decode(String.self)
		guard let eventDate = EventDate(withValue: stringValue) else {
			throw DateError.wrongDateFormat
		}
		self = eventDate
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.value)
	}
}

extension EventDate {
	public var readableString: String {
		let formatter = DateFormatter()
		formatter.locale = Locale.current

		switch self.precision {
		case .year:
			formatter.dateFormat = "yyyy"
		case .month:
			formatter.dateFormat = "MMMM yyyy"
		case .day:
			formatter.dateStyle = .long
			formatter.timeStyle = .none

		}
		return formatter.string(from: self.dateValue)
	}
}
