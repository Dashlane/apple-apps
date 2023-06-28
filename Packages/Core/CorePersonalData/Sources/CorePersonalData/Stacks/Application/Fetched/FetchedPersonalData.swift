import Foundation
import Combine
import DashTypes

@propertyWrapper
public struct FetchedPersonalData<T: PersonalDataCodable> {
    public typealias Values = Dictionary<Identifier, T>.Values
    let fetcher: PersonalDataAutoFetcher<T>

    public init(stack: ApplicationDBStack) {
        fetcher = PersonalDataAutoFetcher(stack: stack)
    }

    public init(stack: ApplicationDatabase,
                logger: Logger,
                databaseEventPublisher: PassthroughSubject<DatabaseEvent, Never>) {
        fetcher = PersonalDataAutoFetcher(stack: stack,
                                          logger: logger,
                                          databaseEventPublisher: databaseEventPublisher)
    }

    init(fetcher: PersonalDataAutoFetcher<T>) throws {
        self.fetcher = fetcher
    }

    public var wrappedValue: Values {
        return fetcher.items
    }

    public var projectedValue: some Publisher {
        fetcher.itemsPublisher
    }
}
