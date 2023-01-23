import Foundation
import Combine

protocol TabActivable {
    var isActive: CurrentValueSubject<Bool, Never> { get }
}
