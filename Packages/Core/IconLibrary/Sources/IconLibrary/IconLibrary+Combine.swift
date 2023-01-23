import Foundation
import Combine
import DashTypes

@available(macOS 10.15, *)
public typealias IconPublisher = AnyPublisher<Icon?, Never>

@available(macOS 10.15, *)
public extension IconLibrary {
        nonisolated func publisher(for request: Request, on queue: DispatchQueue = DispatchQueue.main) -> IconPublisher {
        Future { promise in
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self else {
                    return
                }
                do {
                    let icon = try await self.icon(for: request)
                    promise(.success(icon))
                } catch {
                    promise(.success(nil))
                }
            }
        }
        .receive(on: queue)
        .eraseToAnyPublisher()
    }
}

@available(macOS 10.15, *)
extension IconLibrary where Provider == DomainIconInfoProvider {
        public nonisolated func publisher(for domain: Domain, format: DomainIconFormat, on queue: DispatchQueue = DispatchQueue.main) -> IconPublisher {
        let request = DomainIconInfoProvider.Request(domain: domain, format: format)
        return publisher(for: request, on: queue)
    }
}

@available(macOS 10.15, *)
extension IconLibrary where Provider == BankIconInfoProvider {
        public nonisolated func publisher(forBankCode code: String, isWhiteMode: Bool = false, on queue: DispatchQueue = DispatchQueue.main) -> IconPublisher {
        let request = BankIconLibrary.Request(bankCode: code, isWhiteMode: isWhiteMode)
        return publisher(for: request, on: queue)
    }
}

@available(macOS 10.15, *)
extension IconLibrary where Provider == GravatarIconInfoProvider {
        public nonisolated func publisher(forEmail email: String, on queue: DispatchQueue) -> IconPublisher {
        return publisher(for: .init(email: email), on: queue)
    }
}
