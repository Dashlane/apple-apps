import Foundation

protocol MaverickAction: Codable { }

enum MaverickNonAuthenticatedAction: String, MaverickAction {
    case analysisDisabled
    case evaluatePasswordStrength
    case isReactivationEnabled
    case disableReactivation
    case getAnalysisEnabledStatusOnUrl
}

enum MaverickAuthenticatedAction: String, MaverickAction {
    case analysisDisabled
    case checkMasterPassword
    case dataRequest
    case generatePasswordAndEvaluate
    case usageLog
    case saveRequest
    case objectsAutofilled
    case saveCredentialDisabled
    case signalSaveCredentialDisabled
    case isAutofillPasswordProtected
    case isPwLimitReached
    case askForBiometry
    case fetchSpacesInfo
    case getOtpForCredential
    case openGetPremiumWindows
    case getPasswordGenerationSettings
    case generatePassword
    case saveGeneratedPassword
    case evaluatePassword
    case getAnalysisEnabledStatusOnUrl
}
