import Foundation
import Combine

typealias PopoverOpeningPublisher = PassthroughSubject<PopoverOpening, Never>
enum PopoverOpening {
        case beforeTimeLimit
        case afterTimeLimit
}
