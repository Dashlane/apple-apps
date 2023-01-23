import Foundation
import Combine

class PopoverOpeningService {

    let publisher: PopoverOpeningPublisher
    private var lastResumeTime: Date = Date()

    init() {
        publisher = PassthroughSubject<PopoverOpening, Never>()
    }

    func popoverDidOpen() {
        if openedAtLeastTwoMinutesAgo() {
            publisher.send(.afterTimeLimit)
        } else {
            publisher.send(.beforeTimeLimit)
        }
    }

    func popoverDidClose() {
        self.lastResumeTime = Date()
    }

    private func openedAtLeastTwoMinutesAgo() -> Bool {
        let timePassed = Date().timeIntervalSince(lastResumeTime)
        return timePassed > 120
    }
}
