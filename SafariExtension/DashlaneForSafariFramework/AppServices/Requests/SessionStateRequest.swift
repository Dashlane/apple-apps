import Foundation
import DashTypes
import DashlaneAppKit
import CoreFeature

public protocol SessionInformationProvider {
    var userLogin: String { get }
    func isValidMasterPasswordForSession(masterPassword: String) -> Bool
}

struct NoUserInfo: Decodable { }

enum StateRequestAction: String, Decodable {
    case `init`
    case askLoginPopup
    case openApplication
}

struct SessionStateRequest {

    enum Order {
        case userStatus
        case capacities
    }

    struct Body<UserInfo: Decodable>: Decodable {

        struct Message: Decodable {
            let action: StateRequestAction
            let userInfo: UserInfo?

            enum DefaultKeys: String, CodingKey, CaseIterable {
                case action
                case userInfo
            }

            init(from decoder: Decoder) throws {
                let defaultContainer = try decoder.container(keyedBy: DefaultKeys.self)
                self.action = try defaultContainer.decode(StateRequestAction.self, forKey: .action)
                self.userInfo = try defaultContainer.decodeIfPresent(UserInfo.self, forKey: .userInfo)
            }
        }
        let message: Message
    }

    let userLogin: String?
    let featureService: FeatureServiceProtocol?

    func perform(order: Order) -> Communication? {

        let response: Response?

        switch order {
        case .userStatus:
            response = performUserStatusOrder()
        case .capacities:
            response = performFeaturesUpdateOrder()
        }

        return response?.communication()
    }

    private func performUserStatusOrder() -> Response {
        guard let login = userLogin else {
            return Response(action: .signalAuthStatusLoggedout)
        }
        return Response(action: .signalAuthStatusLoggedin,
                        login: login)
    }

    private func performFeaturesUpdateOrder() -> Response? {
        guard let featureService = self.featureService else { return nil }
        return PluginCapacities(featureService: featureService).makeResponse()
    }

    struct Response {

        enum Action: String {
            case signalAuthStatusLoggedin
            case signalAuthStatusLoggedout
                        case accountFeaturesChanged
                        case accountCapabilitiesChanged
        }

        let subject = "stateResponse"
        let action: Action
        let login: String
        let tabId = -1
        let message: Message

        init(action: Action, login: String = "", content: String? = nil) {
            self.action = action
            self.login = login

            let messsageDictionary = [
                "action" : action.rawValue,
                "login" : login,
                "content": content ?? ""
            ]
            self.message = Message(message: messsageDictionary, tabId: tabId)
        }

        func communication() -> Communication {
            let body = message.rawValue
            return Communication(from: .plugin, to: .background, subject: subject, body: body)
        }
    }
}

struct Message {
    let message: [String: Any]
    let tabId: Int

    var rawValue: [String: Any] {
        return [
            "message" : message,
            "tabId" : tabId
        ]
    }
}

extension SessionStateRequest {
    static func action(from communication: Communication) -> StateRequestAction? {
        guard let request = communication.fromBody(SessionStateRequest.Body<NoUserInfo>.self) else {
            return nil
        }
        return request.message.action
    }

    static func userInfo<UserInfo: Decodable>(from communication: Communication) -> UserInfo? {
        guard let info = communication.fromBody(UserInfo.self) else {
            return nil
        }
        return info
    }
}
