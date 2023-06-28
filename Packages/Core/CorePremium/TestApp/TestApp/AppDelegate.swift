import UIKit
import CorePremium

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        DashlanePremiumManager.setup()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
                    }

    func applicationDidEnterBackground(_ application: UIApplication) {
                    }

    func applicationWillEnterForeground(_ application: UIApplication) {
            }

    func applicationDidBecomeActive(_ application: UIApplication) {
            }

    func applicationWillTerminate(_ application: UIApplication) {
            }

}
