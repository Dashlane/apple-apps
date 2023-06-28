import Foundation
import Combine

@MainActor
class AuthenticationPushViewModel: ObservableObject {

    enum PushError {
        case expired
        case unknown
    }

    enum Action {
        case accept
        case reject
    }

    let notificationService: NotificationServiceProtocol
    let request: AuthenticationRequest
    let completion: (Action?) -> Void

    @Published
    var pushError: PushError?

    var shouldDismiss = false

    init(notificationService: NotificationServiceProtocol,
         request: AuthenticationRequest,
         completion: @escaping (Action?) -> Void) {
        self.notificationService = notificationService
        self.request = request
        self.completion = completion
    }

    func accept() {
        Task {
            do {
                try await notificationService.accept(request)
                shouldDismiss = true
                completion(.accept)
            } catch {
                pushError = .unknown
            }
        }
    }

    func reject() {
        Task {
            do {
                try await notificationService.reject(request)
                shouldDismiss = true
                completion(.reject)
            } catch {
                pushError = .unknown
            }
        }
    }
}
