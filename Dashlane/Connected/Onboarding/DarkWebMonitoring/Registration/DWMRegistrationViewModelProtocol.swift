import Foundation

protocol DWMRegistrationViewModelProtocol: ObservableObject {
    var email: String { get }
    var shouldShowRegistrationRequestSent: Bool { get }
    var shouldShowMailAppsMenu: Bool { get set}
    var mailApps: [MailApp] { get }
    var shouldShowLoading: Bool { get }
    var shouldDisplayError: Bool { get set }
    var errorContent: String { get set }
    var errorDismissalCompletion: (() -> Void)? { get set }

    func register()
    func openMailAppsMenu()
    func openMailApp(_ app: MailApp)
    func userIndicatedEmailWasConfirmed()
    func updateProgressUponDisplay()
    func back()
    func skip()
}
