import Foundation

public protocol SharingGroup {
    var users: [User] { get }
}

extension UserGroup: SharingGroup { }
extension ItemGroup: SharingGroup { }

public extension SharingGroup {
    func user(with userId: UserId) -> User? {
        return users.first {  $0.id == userId }
    }
}
