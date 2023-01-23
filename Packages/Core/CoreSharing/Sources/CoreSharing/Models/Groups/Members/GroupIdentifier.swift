import Foundation
import DashTypes

enum GroupIdentifier {
    case itemGroup(Identifier)
    case userGroup(Identifier)
    
    var id: Identifier {
        switch self {
            case .itemGroup(let id):
                return id
                
            case .userGroup(let id):
                return id
        }
    }
    
    var itemGroupId: Identifier? {
        switch self {
            case .itemGroup(let id):
                return id
                
            case .userGroup:
                return nil
        }
    }
    
    var userGroupId: Identifier? {
        switch self {
            case .itemGroup:
                return nil
                
            case .userGroup(let id):
                return id
        }
    }
}

protocol GroupIdentifiable {
    var groupIdentifier: GroupIdentifier { get }
}

extension UserGroup: GroupIdentifiable {
    var groupIdentifier: GroupIdentifier {
        return .userGroup(id)
    }
}

extension ItemGroup: GroupIdentifiable {
    var groupIdentifier: GroupIdentifier {
        return .itemGroup(id)
    }
}

