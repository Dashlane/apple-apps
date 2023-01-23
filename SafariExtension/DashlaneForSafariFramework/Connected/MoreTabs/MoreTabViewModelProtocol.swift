import Foundation

protocol MoreTabViewModelProtocol {
    
    var login: String {get}

    func openMainApp()
    func askForSupport()
}

class MoreTabViewModelMock: MoreTabViewModelProtocol {

    let login = "_"

    func openMainApp() {}
    func askForSupport() {}

}
