import UserNotifications
import UIKit

final class LocalNotificationService {
    private var lastNotification: (localNotification: LocalNotification, date: Date)?

    private var usageLogService: UsageLogService?
    
    init(usageLogService: UsageLogService?) {
        self.usageLogService = usageLogService
    }
    
    func send(_ localNotification: LocalNotification) {
        
        guard localNotification.shouldSendNotification(previousNotification: lastNotification?.localNotification, previousNotificationDate: lastNotification?.date) else { return }

        let localNotificationContent = localNotification.build()

        let request = UNNotificationRequest(identifier: localNotification.identifier, content: localNotificationContent, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { [weak self] (error) in
            guard error == nil else { return }
            
            self?.lastNotification = (localNotification, Date())
            self?.log(localNotification)
        }
    }
}

private extension LocalNotificationService {
    func log(_ localNotification: LocalNotification) {
        if let notification = localNotification as? OTPLocalNotification {
            usageLogService?.reportOTPNotificationSent(for: notification.domain)
        }
    }
}
