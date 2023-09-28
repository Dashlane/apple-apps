import Foundation
import DashTypes
import CoreSession
import Combine
import LoginKit
import UIKit

public class SessionInactivityAutomaticLogout {

    private let sessionLifeCycleHandler: SessionLifeCycleHandler?
    private let logoutInterval: TimeInterval
    private var logoutTimer: Timer?
    private let unlockedSession: PassthroughSubject<Void, Never>

    var unlockedSessionPublisher: some Publisher<Void, Never> { unlockedSession }

    #if targetEnvironment(macCatalyst)
        private var currentIdleTime: TimeInterval {
        guard let eventType = CGEventType(rawValue: ~0) else {
            return 0
        }
        let seconds = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.hidSystemState, eventType: eventType)
        return TimeInterval(seconds)
    }
    #endif

    init(teamSpaceService: TeamSpacesService,
         sessionLifeCycleHandler: SessionLifeCycleHandler?) {
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.unlockedSession = .init()
                if let automaticLogout = teamSpaceService.availableBusinessTeam?.space.info.forceAutomaticLogout {
                        logoutInterval = TimeInterval(automaticLogout * 60)
                        DispatchQueue.main.async {
                self.setupTimer(timeInterval: self.logoutInterval)
            }
        } else {
            logoutInterval = 0
        }

    }

    private func setupTimer(timeInterval: TimeInterval) {
        #if targetEnvironment(macCatalyst)
        logoutTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
                        let timeBeforeNextCheck = self.logoutInterval - self.currentIdleTime
            if timeBeforeNextCheck > 0 {
                                self.setupTimer(timeInterval: timeBeforeNextCheck)
            } else {
                                self.sessionLifeCycleHandler?.automaticLogout()
            }

        })
        #endif
    }

    func didLoadSession() {
        self.unlockedSession.send()
    }
}
