import CoreSession
import Foundation

extension QRCodeFlowStateMachine: LoginKitServicesInjecting {}
extension QRCodeScanStateMachine: LoginKitServicesInjecting {}
extension PassphraseVerificationStateMachine: LoginKitServicesInjecting {}
extension SecurityChallengeFlowStateMachine: LoginKitServicesInjecting {}
extension SecurityChallengeTransferStateMachine: LoginKitServicesInjecting {}
extension DeviceTransferLoginFlowStateMachine: LoginKitServicesInjecting {}
extension ThirdPartyOTPLoginStateMachine: LoginKitServicesInjecting {}
extension SSORemoteStateMachine: LoginKitServicesInjecting {}
extension SSOLocalStateMachine: LoginKitServicesInjecting {}
