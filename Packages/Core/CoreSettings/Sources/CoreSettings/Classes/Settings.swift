import CoreData
import DashTypes

final public class Settings {

        public let register: SettingsRegister = SettingsRegister()
    public let configuration: SettingsConfiguration
    public let logger: Logger

    private var dataStack: DataStack
    public weak var delegate: SettingsDelegate?

                    public func value<T: DataConvertible>(for identifier: String) -> T? {
        guard let metadata = register[identifier] else {
            preconditionFailure("Trying to use unregistered setting with identifier: \(identifier)")
        }
        guard (metadata.secure && delegate != nil) || !metadata.secure else {
            fatalError("Identifier is secure, but no delegate for security provided")
        }
        guard metadata.type == T.self else {
            return nil
        }
        var kvp: KeyValuePair?
        let context = dataStack.currentThreadContext
        var kvpValue: Data?
        var isSecure: Bool = false
        context.performAndWait {
            let request: NSFetchRequest<KeyValuePair> = KeyValuePair.fetchRequest()
            request.predicate = NSPredicate(format: "_", identifier)
            let result = try? context.fetch(request)
            kvp = result?.first
            kvpValue = kvp?.value
            isSecure = kvp?.secure ?? false
        }
        guard let kvpValue else {
            return nil
        }
        if isSecure == true {
            guard let decrypted = delegate?.decrypt(data: kvpValue) else {
                return nil
            }
            return T(binaryData: decrypted)
        }
        return T(binaryData: kvpValue)
    }

        public func set<T: DataConvertible>(value: T?, forIdentifier identifier: String) {
        guard let metadata = register[identifier] else {
            preconditionFailure("Trying to set unregistered setting with identifier: \(identifier)")
        }
        guard (metadata.secure && delegate != nil) || !metadata.secure else {
            fatalError("Identifier is secure, but no delegate for security provided")
        }
        guard value == nil || metadata.type == T.self else {
            preconditionFailure("Trying to set a setting of type \(metadata.type.self) with a value of type \(T.self)")
        }
        let context = dataStack.currentThreadContext
        context.performAndWait {
            do {
                let request: NSFetchRequest<KeyValuePair> = KeyValuePair.fetchRequest()
                request.predicate = NSPredicate(format: "_", identifier)
                let results: [KeyValuePair]? = try? context.fetch(request)
                if let kvp = results?.first,
                    value == nil {
                    context.delete(kvp)
                    try context.recursiveSave()
                    return
                }
                guard let value = value else {
                    return
                }
                                let kvp = results?.first ?? NSEntityDescription.insertNewObject(forEntityName: "KeyValuePair", into: context) as! KeyValuePair
                kvp.key = identifier
                if metadata.secure {
                    kvp.value = self.delegate?.encrypt(data: value.binaryData)
                } else {
                    kvp.value = value.binaryData
                }
                kvp.lastUpdate = Date()
                kvp.secure = metadata.secure
                try context.recursiveSave()
            } catch {
                context.rollback()
                logger.fatal("Cannot save settings for key \(identifier)", error: error)
            }
        }
    }

        public func delete(_ identifier: String) {
        set(value: nil as Data?, forIdentifier: identifier)
    }

        public init(configuration: SettingsConfiguration, logger: Logger) {
        self.configuration = configuration
        self.logger = logger
        guard let dataStack = DataStack(modelURL: configuration.modelURL,
                                 storeURL: configuration.storeURL) else {
                                    preconditionFailure("Settings failed to initialize DataStack")
        }
        self.dataStack = dataStack
    }

}
