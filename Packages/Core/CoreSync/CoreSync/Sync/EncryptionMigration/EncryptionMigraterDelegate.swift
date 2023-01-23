import Foundation
import DashTypes

public protocol EncryptionMigraterDelegate: AnyObject {
    associatedtype Output
    
        func didProgress(_ progression: EncryptionMigrater<Self>.Progression)
    
                    func complete(with timestamp: Timestamp, completionHandler: @escaping (Result<Output, Swift.Error>) -> Void)

    
    func didFinish(with result: Result<Output, EncryptionMigrater<Self>.MigraterError>)
}
