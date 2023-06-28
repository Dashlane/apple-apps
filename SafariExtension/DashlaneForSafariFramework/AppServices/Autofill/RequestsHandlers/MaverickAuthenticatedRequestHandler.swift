import Foundation
import DashTypes
import CorePasswords

struct MaverickAuthenticatedRequestHandler: MaverickRequestHandler {

    let nonAuthenticatedRequestHandler: MaverickNonAuthenticatedRequestHandler
    let sessionServicesContainer: SessionServicesContainer
    let logger: Logger
    
    init(nonAuthenticatedRequestHandler: MaverickNonAuthenticatedRequestHandler,
         sessionServicesContainer: SessionServicesContainer,
         logger: Logger) {
        self.nonAuthenticatedRequestHandler = nonAuthenticatedRequestHandler
        self.sessionServicesContainer = sessionServicesContainer
        self.logger = logger
    }

    func performOrder(_ order: MaverickOrder) async throws -> Communication? {

        guard let maverickAction: MaverickAuthenticatedAction = order.message.maverickAction() else {
                        return try nonAuthenticatedRequestHandler.performOrder(order)
        }

        logger.debug("Will perform authenticated maverick order \"\(maverickAction)\"")

        let handlerResponse: AnyEncodable?

                        var rawResponse: String?

        switch maverickAction {
        case .analysisDisabled:
            handlerResponse = try AnalysisIsDisabledHandler(maverickOrderMessage: order.message,
                                                            sessionState: .loggedIn(sessionServicesContainer),
                                                            domainParser: sessionServicesContainer.appServices.domainParser)
                .makeResponse()
        case .dataRequest:
            handlerResponse = nil
            rawResponse = try sessionServicesContainer.viewModelFactory.makeDataRequestHandler(maverickOrderMessage: order.message).performOrder()
        case .isPwLimitReached:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeIsPasswordLimitReachedHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .isAutofillPasswordProtected:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeIsAutofillPasswordProtectedHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .checkMasterPassword:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeCheckMasterPasswordHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .askForBiometry:
            return await sessionServicesContainer.viewModelFactory.makeAskForBiometryHandler(maverickOrderMessage: order.message)
                .performOrder()?
                .communication()
        case .fetchSpacesInfo:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeFetchSpacesInfoHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .signalSaveCredentialDisabled:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeSignalSaveCredentialDisabledHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .saveCredentialDisabled:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeSaveCredentialDisabledHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .saveRequest:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeSaveRequestHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .getOtpForCredential:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeGetOTPForCredentialHandler(maverickOrderMessage: order.message)
                .makeResponse()
        case .generatePasswordAndEvaluate:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeGenerateAndEvaluatePasswordHandler(maverickOrderMessage: order.message).makeResponse()
        case .getPasswordGenerationSettings:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeGetPasswordGenerationSettingsHandler(maverickOrderMessage: order.message).makeResponse()
        case .evaluatePassword:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeEvaluatePasswordHandler(maverickOrderMessage: order.message).makeResponse()
        case .saveGeneratedPassword:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeSaveGeneratedPasswordHandler(maverickOrderMessage: order.message).makeResponse()
        case .generatePassword:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeGeneratePasswordHandler(maverickOrderMessage: order.message).makeResponse()
        case .objectsAutofilled:
            handlerResponse = try sessionServicesContainer.viewModelFactory.makeObjectsAutofilledHandler(maverickOrderMessage: order.message).makeResponse()
        case .openGetPremiumWindows:
            handlerResponse = try OpenPremiumOrder(maverickOrderMessage: order.message).makeResponse()
        case .usageLog:
            handlerResponse = nil
        case .getAnalysisEnabledStatusOnUrl:
            let handler = sessionServicesContainer.viewModelFactory.makeAuthenticatedAnalysisStatusHandler()
            handlerResponse = try GetAnalysisEnabledStatusOnUrlHandler(maverickOrderMessage: order.message, sessionState: .loggedIn(handler)).makeResponse()
        }

        guard let content = handlerResponse?.jsonRepresentation ?? rawResponse else {
            return nil
        }
        let message = MaverickResponseMessage(content: content)
        return Communication.from(message, order: order)
    }
}
