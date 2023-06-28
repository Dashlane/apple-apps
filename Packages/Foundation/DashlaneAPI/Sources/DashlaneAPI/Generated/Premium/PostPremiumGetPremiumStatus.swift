import Foundation
extension UserDeviceAPIClient.Premium {
        public struct GetPremiumStatus: APIRequest {
        public static let endpoint: Endpoint = "/premium/GetPremiumStatus"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getPremiumStatus: GetPremiumStatus {
        GetPremiumStatus(api: api)
    }
}

extension UserDeviceAPIClient.Premium.GetPremiumStatus {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Premium.GetPremiumStatus {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case b2cStatus = "b2cStatus"
            case capabilities = "capabilities"
            case b2bStatus = "b2bStatus"
            case currentTimestampUnix = "currentTimestampUnix"
        }

                public let b2cStatus: B2cStatus

        public let capabilities: [Capabilities]

                public let b2bStatus: B2bStatus?

        public let currentTimestampUnix: Int?

                public struct B2cStatus: Codable, Equatable {

                        public enum StatusCode: String, Codable, Equatable, CaseIterable {
                case free = "free"
                case subscribed = "subscribed"
                case legacy = "legacy"
            }

                        public enum PlanFeature: String, Codable, Equatable, CaseIterable {
                case premium = "premium"
                case essentials = "essentials"
                case premiumplus = "premiumplus"
                case backupForAll = "backup-for-all"
            }

                        public enum PlanType: String, Codable, Equatable, CaseIterable {
                case amazon = "amazon"
                case freeTrial = "free_trial"
                case invoice = "invoice"
                case ios = "ios"
                case iosRenewable = "ios_renewable"
                case mac = "mac"
                case macRenewable = "mac_renewable"
                case offer = "offer"
                case partner = "partner"
                case paypal = "paypal"
                case paypalRenewable = "paypal_renewable"
                case playstore = "playstore"
                case playstoreRenewable = "playstore_renewable"
                case stripe = "stripe"
            }

            private enum CodingKeys: String, CodingKey {
                case statusCode = "statusCode"
                case isTrial = "isTrial"
                case autoRenewal = "autoRenewal"
                case endDateUnix = "endDateUnix"
                case familyStatus = "familyStatus"
                case planFeature = "planFeature"
                case planName = "planName"
                case planType = "planType"
                case previousPlan = "previousPlan"
                case startDateUnix = "startDateUnix"
            }

                        public let statusCode: StatusCode

                        public let isTrial: Bool

                        public let autoRenewal: Bool

            public let endDateUnix: Int?

            public let familyStatus: FamilyStatus?

            public let planFeature: PlanFeature?

            public let planName: String?

            public let planType: PlanType?

            public let previousPlan: PreviousPlan?

            public let startDateUnix: Int?

                        public struct FamilyStatus: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case isAdmin = "isAdmin"
                    case familyId = "familyId"
                    case planName = "planName"
                }

                public let isAdmin: Bool

                public let familyId: Int

                public let planName: String

                public init(isAdmin: Bool, familyId: Int, planName: String) {
                    self.isAdmin = isAdmin
                    self.familyId = familyId
                    self.planName = planName
                }
            }

                        public struct PreviousPlan: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case planName = "planName"
                    case endDateUnix = "endDateUnix"
                }

                public let planName: String

                public let endDateUnix: Int

                public init(planName: String, endDateUnix: Int) {
                    self.planName = planName
                    self.endDateUnix = endDateUnix
                }
            }

            public init(statusCode: StatusCode, isTrial: Bool, autoRenewal: Bool, endDateUnix: Int? = nil, familyStatus: FamilyStatus? = nil, planFeature: PlanFeature? = nil, planName: String? = nil, planType: PlanType? = nil, previousPlan: PreviousPlan? = nil, startDateUnix: Int? = nil) {
                self.statusCode = statusCode
                self.isTrial = isTrial
                self.autoRenewal = autoRenewal
                self.endDateUnix = endDateUnix
                self.familyStatus = familyStatus
                self.planFeature = planFeature
                self.planName = planName
                self.planType = planType
                self.previousPlan = previousPlan
                self.startDateUnix = startDateUnix
            }
        }

                public struct Capabilities: Codable, Equatable {

                        public enum Capability: String, Codable, Equatable, CaseIterable {
                case autofillWithPhishingPrevention = "autofillWithPhishingPrevention"
                case creditMonitoring = "creditMonitoring"
                case dataLeak = "dataLeak"
                case devicesLimit = "devicesLimit"
                case identityRestoration = "identityRestoration"
                case identityTheftProtection = "identityTheftProtection"
                case multipleAccounts = "multipleAccounts"
                case passwordChanger = "passwordChanger"
                case passwordsLimit = "passwordsLimit"
                case secureFiles = "secureFiles"
                case secureNotes = "secureNotes"
                case secureWiFi = "secureWiFi"
                case securityBreach = "securityBreach"
                case sharingLimit = "sharingLimit"
                case sync = "sync"
                case yubikey = "yubikey"
            }

            private enum CodingKeys: String, CodingKey {
                case capability = "capability"
                case enabled = "enabled"
                case info = "info"
            }

            public let capability: Capability

            public let enabled: Bool

                        public let info: Info?

                        public struct Info: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case reason = "reason"
                }

                                public let reason: String?

                public init(reason: String? = nil) {
                    self.reason = reason
                }
            }

            public init(capability: Capability, enabled: Bool, info: Info? = nil) {
                self.capability = capability
                self.enabled = enabled
                self.info = info
            }
        }

                public struct B2bStatus: Codable, Equatable {

                        public enum StatusCode: String, Codable, Equatable, CaseIterable {
                case notInTeam = "not_in_team"
                case proposed = "proposed"
                case inTeam = "in_team"
            }

            private enum CodingKeys: String, CodingKey {
                case statusCode = "statusCode"
                case currentTeam = "currentTeam"
                case pastTeams = "pastTeams"
            }

            public let statusCode: StatusCode

            public let currentTeam: CurrentTeam?

            public let pastTeams: [PastTeams]?

                        public struct CurrentTeam: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case planName = "planName"
                    case teamId = "teamId"
                    case planFeature = "planFeature"
                    case joinDateUnix = "joinDateUnix"
                    case teamMembership = "teamMembership"
                    case teamInfo = "teamInfo"
                    case associatedEmail = "associatedEmail"
                    case invitationDateUnix = "invitationDateUnix"
                    case isRenewalStopped = "isRenewalStopped"
                    case recoveryHash = "recoveryHash"
                    case teamName = "teamName"
                }

                public let planName: String

                public let teamId: Int

                public let planFeature: String

                public let joinDateUnix: Int

                public let teamMembership: PremiumGetStatusTeamMembership

                public let teamInfo: PremiumGetStatusTeamInfo

                public let associatedEmail: String?

                public let invitationDateUnix: Int?

                public let isRenewalStopped: Bool?

                public let recoveryHash: String?

                public let teamName: String?

                public init(planName: String, teamId: Int, planFeature: String, joinDateUnix: Int, teamMembership: PremiumGetStatusTeamMembership, teamInfo: PremiumGetStatusTeamInfo, associatedEmail: String? = nil, invitationDateUnix: Int? = nil, isRenewalStopped: Bool? = nil, recoveryHash: String? = nil, teamName: String? = nil) {
                    self.planName = planName
                    self.teamId = teamId
                    self.planFeature = planFeature
                    self.joinDateUnix = joinDateUnix
                    self.teamMembership = teamMembership
                    self.teamInfo = teamInfo
                    self.associatedEmail = associatedEmail
                    self.invitationDateUnix = invitationDateUnix
                    self.isRenewalStopped = isRenewalStopped
                    self.recoveryHash = recoveryHash
                    self.teamName = teamName
                }
            }

                        public struct PastTeams: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case status = "status"
                    case revokeDateUnix = "revokeDateUnix"
                    case teamId = "teamId"
                    case planFeature = "planFeature"
                    case joinDateUnix = "joinDateUnix"
                    case teamMembership = "teamMembership"
                    case teamInfo = "teamInfo"
                    case associatedEmail = "associatedEmail"
                    case invitationDateUnix = "invitationDateUnix"
                    case shouldDelete = "shouldDelete"
                    case teamName = "teamName"
                }

                public let status: String

                public let revokeDateUnix: Int

                public let teamId: Int

                public let planFeature: String

                public let joinDateUnix: Int

                public let teamMembership: PremiumGetStatusTeamMembership

                public let teamInfo: PremiumGetStatusTeamInfo

                public let associatedEmail: String?

                public let invitationDateUnix: Int?

                public let shouldDelete: Bool?

                public let teamName: String?

                public init(status: String, revokeDateUnix: Int, teamId: Int, planFeature: String, joinDateUnix: Int, teamMembership: PremiumGetStatusTeamMembership, teamInfo: PremiumGetStatusTeamInfo, associatedEmail: String? = nil, invitationDateUnix: Int? = nil, shouldDelete: Bool? = nil, teamName: String? = nil) {
                    self.status = status
                    self.revokeDateUnix = revokeDateUnix
                    self.teamId = teamId
                    self.planFeature = planFeature
                    self.joinDateUnix = joinDateUnix
                    self.teamMembership = teamMembership
                    self.teamInfo = teamInfo
                    self.associatedEmail = associatedEmail
                    self.invitationDateUnix = invitationDateUnix
                    self.shouldDelete = shouldDelete
                    self.teamName = teamName
                }
            }

            public init(statusCode: StatusCode, currentTeam: CurrentTeam? = nil, pastTeams: [PastTeams]? = nil) {
                self.statusCode = statusCode
                self.currentTeam = currentTeam
                self.pastTeams = pastTeams
            }
        }

        public init(b2cStatus: B2cStatus, capabilities: [Capabilities], b2bStatus: B2bStatus? = nil, currentTimestampUnix: Int? = nil) {
            self.b2cStatus = b2cStatus
            self.capabilities = capabilities
            self.b2bStatus = b2bStatus
            self.currentTimestampUnix = currentTimestampUnix
        }
    }
}
