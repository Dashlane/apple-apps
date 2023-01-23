import Foundation

public enum UserEvent { 

}

public enum AnonymousEvent { 

}

public enum Report {
    
}

public enum Definition {
    
}

public protocol EventProtocol: Encodable {
    static var isPriority: Bool { get }
}
public protocol UserEventProtocol: EventProtocol { }

public protocol AnonymousEventProtocol: EventProtocol { }
