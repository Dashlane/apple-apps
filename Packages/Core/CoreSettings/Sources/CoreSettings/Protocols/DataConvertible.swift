import Foundation

public protocol DataConvertible {
    
    var binaryData: Data { get }
    init?(binaryData: Data)
    
}

protocol NumberDataConvertible: DataConvertible {
    
}

extension NumberDataConvertible {
    
    public var binaryData: Data {
        var i = self
        return Data(bytes: &i, count: MemoryLayout<Self>.size)
    }
    
    public init?(binaryData: Data) {
        if binaryData.count != MemoryLayout<Self>.size {
            return nil
        }
        self = binaryData.withUnsafeBytes { unsafeRawBufferPointer -> Self in
            let baseRawPointer = unsafeRawBufferPointer.baseAddress
            let basePointer = baseRawPointer!.bindMemory(to: Self.self,
                                                         capacity: MemoryLayout<Self>.size)
            return basePointer.pointee
        }
    }
    
}

extension String: DataConvertible {
    
    public var binaryData: Data {
        if self.isEmpty {
            return "\0".data(using: .utf8)!
        }
        return self.data(using: .utf8)!
    }

    public init?(binaryData: Data) {
        guard let str = String(data: binaryData, encoding: .utf8) else {
            return nil
        }
        self = str.trimmingCharacters(in: CharacterSet(charactersIn:"\0"))
    }
    
}

extension Date: DataConvertible {
    
    public var binaryData: Data {
        return self.timeIntervalSince1970.binaryData
    }
    
    public init?(binaryData: Data) {
        guard let timestamp = Double(binaryData: binaryData) else {
            return nil
        }
        self = Date(timeIntervalSince1970: timestamp)
    }

}

extension Int: NumberDataConvertible {
    
}

extension Double: NumberDataConvertible {
    
}

extension Bool: NumberDataConvertible {
    
}

extension Data: DataConvertible {
    
    public var binaryData: Data {
        return self
    }
    
    public init?(binaryData: Data) {
        self = binaryData
    }

}

protocol CollectionDataConvertible: DataConvertible  {
    
}

extension CollectionDataConvertible {
    
    public var binaryData: Data {
        return try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    public init?(binaryData: Data) {
		self = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(binaryData) as! Self
    }
    
}

extension Array: CollectionDataConvertible {
    
}

extension Dictionary: CollectionDataConvertible {
    
}

extension Set: CollectionDataConvertible {
    
}
