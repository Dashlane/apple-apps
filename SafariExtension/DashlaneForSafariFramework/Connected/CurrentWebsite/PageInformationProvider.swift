import Foundation
import SafariServices

protocol PageInformationProvider {
    func currentPageURL(completion: @escaping (URL?) -> Void)
}

struct SafariPageInformationProvider: PageInformationProvider {

    func currentPageURL(completion: @escaping (URL?) -> Void) {
        SFSafariApplication.getActiveWindow { (window) in
            window?.getActiveTab { (tab) in
                tab?.getActivePage(completionHandler: { (page) in
                    page?.getPropertiesWithCompletionHandler( { (properties) in
                        DispatchQueue.main.async {
                            completion(properties?.url)
                        }
                    })
                })
            }
        }
    }
}

struct PageInformationProviderMock: PageInformationProvider {

    let url: URL

    func currentPageURL(completion: @escaping (URL?) -> Void) {
        completion(url)
    }
}
