import Foundation
import Security

public class KeychainItemWrapper {
    
    var genericPasswordQuery = [NSObject: AnyObject]()
    var keychainItemData = [String: AnyObject]()
        
    public init(identifier: String, accessGroup: String?) {
        self.genericPasswordQuery[kSecClass] = kSecClassGenericPassword
        self.genericPasswordQuery[kSecAttrGeneric] = identifier as AnyObject?
        
        if (accessGroup != nil) {
            if TARGET_IPHONE_SIMULATOR != 1 {
                self.genericPasswordQuery[kSecAttrAccessGroup] = accessGroup as AnyObject?
            }
        }
        
        self.genericPasswordQuery[kSecMatchLimit] = kSecMatchLimitOne
        self.genericPasswordQuery[kSecReturnAttributes] = kCFBooleanTrue
        
        var outDict: AnyObject?

        let copyMatchingResult = SecItemCopyMatching(genericPasswordQuery as CFDictionary, &outDict)
        
        if copyMatchingResult != noErr {
            self.resetKeychain()
            
            self.keychainItemData[kSecAttrGeneric as String] = identifier as AnyObject?
            if (accessGroup != nil) {
                if TARGET_IPHONE_SIMULATOR != 1 {
                    self.keychainItemData[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
                }
            }
        } else {
            self.keychainItemData = self.secItemDataToDict(data: outDict as! [String : AnyObject])
        }
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            return self.keychainItemData[key]
        }
        
        set(newValue) {
            keychainItemData[key] = newValue
            self.writeKeychain()
        }
    }
    
    func resetKeychain() {
        
        if !self.keychainItemData.isEmpty {
            let tempDict = self.dictToSecItemData(dict: self.keychainItemData)
            var junk = noErr
            junk = SecItemDelete(tempDict as CFDictionary)
            
            assert(junk == noErr || junk == errSecItemNotFound, "Failed to delete current dict")
        }
        
        self.keychainItemData[kSecAttrAccount as String] = "" as AnyObject?
        self.keychainItemData[kSecAttrLabel as String] = "" as AnyObject?
        self.keychainItemData[kSecAttrDescription as String] = "" as AnyObject?
        
        self.keychainItemData[kSecValueData as String] = "" as AnyObject?
    }
    
    private func secItemDataToDict(data: [String: AnyObject]) -> [String: AnyObject] {
        var returnDict = [String: AnyObject]()
        for (key, value) in data {
            returnDict[key] = value
        }
        
        returnDict[kSecReturnData as String] = kCFBooleanTrue
        returnDict[kSecClass as String] = kSecClassGenericPassword
        
        var passwordData: AnyObject?
        
                        let queryDict = returnDict
        
        let copyMatchingResult = SecItemCopyMatching(queryDict as CFDictionary, &passwordData)
        
        if copyMatchingResult != noErr {
            assert(false, "No matching item found in keychain")
        } else {
            let retainedValuesData = passwordData as! Data
            do {
                guard let val = String(data: retainedValuesData, encoding: .utf8) else {
                    throw KeychainError.unknown
                }
            
                returnDict.removeValue(forKey: kSecReturnData as String)
                returnDict[kSecValueData as String] = val as AnyObject?

            } catch let error as NSError {
                assert(false, "Error parsing json value. \(error.localizedDescription)")
            }
        }
        
        return returnDict
    }
    
    private func dictToSecItemData(dict: [String: AnyObject]) -> [String: AnyObject] {
        var returnDict = [String: AnyObject]()
        
        for (key, value) in self.keychainItemData {
            returnDict[key] = value
        }
        
        returnDict[kSecClass as String] = kSecClassGenericPassword
        
        do {
            guard let passwordString = dict[kSecValueData as String] else {
                throw KeychainError.unknown
            }
            returnDict[kSecValueData as String] = passwordString.data(using: String.Encoding.utf8.rawValue) as AnyObject
        } catch let error as NSError {
            assert(false, "Error paring json value. \(error.localizedDescription)")
        }
        
        return returnDict
    }
    
    private func writeKeychain() {
        var attributes: AnyObject?
        var updateItem = [String: AnyObject]()
        
        var result: OSStatus?
        
        let copyMatchingResult = SecItemCopyMatching(self.genericPasswordQuery as CFDictionary, &attributes)
        
        if copyMatchingResult != noErr {
            result = SecItemAdd(self.dictToSecItemData(dict: self.keychainItemData) as CFDictionary, nil)
            assert(result == noErr, "Failed to add keychain item")
        } else {

            for (key, value) in attributes as! [String: AnyObject] {
                updateItem[key] = value
            }
            updateItem[kSecClass as String] = self.genericPasswordQuery[kSecClass]
            
            var tempCheck = self.dictToSecItemData(dict: self.keychainItemData)
            tempCheck.removeValue(forKey: kSecClass as String)
            
#if targetEnvironment(simulator)
            tempCheck.removeValue(forKey: kSecAttrAccessGroup as String)
#endif
            
            result = SecItemUpdate(updateItem as CFDictionary, tempCheck as CFDictionary)
            assert(result == noErr, "Failed to update keychain item")
        }
    }
}
