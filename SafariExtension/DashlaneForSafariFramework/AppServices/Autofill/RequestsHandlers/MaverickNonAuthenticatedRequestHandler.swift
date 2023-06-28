import Foundation
import DashTypes
import CorePasswords
import Logger

struct MaverickNonAuthenticatedRequestHandler: MaverickRequestHandler, SessionServicesInjecting {

    let appServices: AutofillAppServicesContainer
    let logger: Logger

    func performOrder(_ order: MaverickOrder) throws -> Communication? {

        guard let maverickAction: MaverickNonAuthenticatedAction = order.message.maverickAction() else {
            assertionFailure("The non authenticated maverick action we received is not handled. \(order.message.action)")
            return nil
        }

        logger.debug("Will perform non authenticated maverick order \"\(maverickAction)\"")

        let handlerResponse: AnyEncodable?

        switch maverickAction {
        case .analysisDisabled:
            handlerResponse = try AnalysisIsDisabledHandler(maverickOrderMessage: order.message, sessionState: .loggedOut, domainParser: appServices.domainParser)
                .makeResponse()
        case .isReactivationEnabled:
            handlerResponse = try IsReactivationEnabledHandler(maverickOrderMessage: order.message, settings: appServices.appSettings).makeResponse()
        case .evaluatePasswordStrength:
            handlerResponse = try PasswordStrengthHandler(maverickOrderMessage: order.message, passwordEvaluator: appServices.passwordEvaluator).makeResponse()
        case .disableReactivation:
            handlerResponse = try DisableReactivationHandler(maverickOrderMessage: order.message, settings: appServices.appSettings).makeResponse()
        case .getAnalysisEnabledStatusOnUrl:
            handlerResponse = try GetAnalysisEnabledStatusOnUrlHandler(maverickOrderMessage: order.message, sessionState: .loggedOut).makeResponse()
        }

        guard let content = handlerResponse?.jsonRepresentation else {
            return nil
        }
        let message = MaverickResponseMessage(content: content)
        return Communication.from(message, order: order)
    }
}
