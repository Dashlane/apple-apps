import Foundation

@propertyWrapper
public struct CalendarDateFormatted: Codable, Equatable {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public var wrappedValue: Date?

    public var projectedValue: DateComponents? {
        guard let date = wrappedValue else {
            return nil
        }
        return Calendar.current.dateComponents(in: TimeZone.current, from: date)
    }
    
    public init() {
        
    }
    
    public init(rawValue: String?) {
        guard let rawValue = rawValue,
              !rawValue.isEmpty,
              let date =  Self.formatter.date(from: rawValue) else {
            self.wrappedValue = nil
            return
        }

        self.wrappedValue = date
    }
    
        public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawDate = try container.decode(String.self)
        guard !rawDate.isEmpty,
        let date =  Self.formatter.date(from: rawDate) else {
            self.wrappedValue = nil
            return
        }
        
        self.wrappedValue = date
    }

    public init(_ date: Date) {
        self.wrappedValue = date
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        guard let date = wrappedValue else {
            try container.encodeNil()
            return
        }
        try container.encode( Self.formatter.string(from: date))
    }
}


