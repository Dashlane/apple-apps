public extension Dictionary where Key == String, Value == Any {

    subscript(object key: Key) -> [String: Any]? {
        get {
            return self[key] as? [String: Any]
        }
        set {
            self[key] = newValue
        }
    }

    subscript(objectArray key: Key) -> [[String: Any]]? {
        get {
            return self[key] as? [[String: Any]]
        }
        set {
            self[key] = newValue
        }
    }

    subscript(string key: Key) -> String? {
        get {
            return self[key] as? String
        }
        set {
            self[key] = newValue
        }
    }

    subscript(int key: Key) -> Int? {
        get {
            return self[key] as? Int
        }
        set {
            self[key] = newValue
        }
    }

    subscript(uint key: Key) -> UInt? {
        get {
            return self[key] as? UInt
        }
        set {
            self[key] = newValue
        }
    }

    subscript(bool key: Key) -> Bool? {
        get {
            return self[key] as? Bool
        }
        set {
            self[key] = newValue
        }
    }

    subscript(double key: Key) -> Double? {
        get {
            return self[key] as? Double
        }
        set {
            self[key] = newValue
        }
    }

    subscript(float key: Key) -> Float? {
        get {
            return self[key] as? Float
        }
        set {
            self[key] = newValue
        }
    }
}
