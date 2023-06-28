import Foundation
import SafariServices

final class DashlaneSafariPage: CustomStringConvertible, Equatable  {
    
    let page: SFSafariPage
    let tabId: Int
    var url: String? {
        didSet {
            guard url != oldValue else {
                return
            }
            self.didUpdate(self)
        }
    }
    var title: String?
    
    var didUpdate: (DashlaneSafariPage) -> Void
    
    init(page: SFSafariPage, tabId: Int, didUpdate: @escaping (DashlaneSafariPage) -> Void) {
        self.page = page
        self.tabId = tabId
        self.didUpdate = didUpdate
    }
    
    var description: String {
        return "DashlaneSafariPage tabId= \(String(describing: tabId)) url= \(String(describing: url))"
    }
    
    func update(completion: (() -> Void)? = nil)  {
        completion?()
            }
    
    static func == (lhs: DashlaneSafariPage, rhs: DashlaneSafariPage) -> Bool {
        return lhs.tabId == rhs.tabId
    }
}
