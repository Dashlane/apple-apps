import Foundation

public struct DeviceHardware {
    public static var name: String = {
                #if targetEnvironment(macCatalyst) || os(macOS)
        return ioServiceName ?? ""
#else
        return utsnameName
#endif
    }()
    
    private static var utsnameName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
#if targetEnvironment(macCatalyst) || os(macOS)
    private static var ioServiceName: String? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        guard service > 0 else {
            return nil
        }
        
        defer {
            IOObjectRelease(service)
        }
        
        guard let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data,
              let modelIdentifier = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) else {
                  return nil
              }
        return String(cString: modelIdentifier)
    }
    #endif
}
