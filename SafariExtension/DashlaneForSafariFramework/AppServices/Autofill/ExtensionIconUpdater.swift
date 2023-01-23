import DashTypes
import SafariServices

public final class ExtensionIconUpdater {
    
    private static var iconPrefix: String {
        #if DEBUG
        return "safari-extension-debug"
        #else
        return "safari-extension"
        #endif
    }
    
    static func setIconEnabled(_ enabled: Bool) {
        let imageName = "\(iconPrefix)-\(enabled ? "active" : "inactive")"
        
        guard let image = NSImage(named: imageName) else { return }
        
        SFSafariApplication.getActiveWindow { window in
            window?.getToolbarItem { toolbarItem in
                toolbarItem?.setImage(image)
            }
        }
    }
}
