import Foundation
import UIKit
import DashlaneAppKit

final class PairingStatusAnnouncementViewModel: ObservableObject {
    
    enum DashlaneApplicationStatus {
        case notInstalled
        case installedButAccountNotCreated
        case installedButNotPaired
        
        init() {
            
            guard let url = URL(string: "dashlane:///"), UIApplication.shared.canOpenURL(url) else {
                self = .notInstalled
                return
            }
            
            guard let contents = try? FileManager.default.contentsOfDirectory(at: ApplicationGroup.fiberSessionsURL, includingPropertiesForKeys: nil), !contents.isEmpty else {
                self  = .installedButAccountNotCreated
                return
            }
            self = .installedButNotPaired
        }
    }
    
    @Published
    var status: DashlaneApplicationStatus
    
    init() {
        self.status = DashlaneApplicationStatus()
    }
    
    fileprivate init(status: DashlaneApplicationStatus) {
        self.status = status
    }
    
    func refreshStatus() {
        self.status = DashlaneApplicationStatus()
    }
}

extension PairingStatusAnnouncementViewModel {
    static var mockNotInstalled: PairingStatusAnnouncementViewModel {
        PairingStatusAnnouncementViewModel(status: .notInstalled)
    }
    
    static var mockNotPaired: PairingStatusAnnouncementViewModel {
        PairingStatusAnnouncementViewModel(status: .installedButNotPaired)
    }
}
