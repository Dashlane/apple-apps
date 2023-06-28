import Foundation
extension UserDeviceAPIClient.Premium {
        public struct GetSubscriptionInfo: APIRequest {
        public static let endpoint: Endpoint = "/premium/GetSubscriptionInfo"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getSubscriptionInfo: GetSubscriptionInfo {
        GetSubscriptionInfo(api: api)
    }
}

extension UserDeviceAPIClient.Premium.GetSubscriptionInfo {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Premium.GetSubscriptionInfo {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case b2cSubscription = "b2cSubscription"
            case b2bSubscription = "b2bSubscription"
        }

        public let b2cSubscription: B2cSubscription

        public let b2bSubscription: B2bSubscription?

                public struct B2cSubscription: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case autoRenewInfo = "autoRenewInfo"
                case hasInvoices = "hasInvoices"
                case billingInformation = "billingInformation"
            }

            public let autoRenewInfo: AutoRenewInfo

                        public let hasInvoices: Bool

            public let billingInformation: PremiumGetSubscriptionInfoBillingInformation?

                        public struct AutoRenewInfo: Codable, Equatable {

                                public enum Periodicity: String, Codable, Equatable, CaseIterable {
                    case yearly = "yearly"
                    case monthly = "monthly"
                    case other = "other"
                }

                                public enum Trigger: String, Codable, Equatable, CaseIterable {
                    case manual = "manual"
                    case automatic = "automatic"
                }

                private enum CodingKeys: String, CodingKey {
                    case theory = "theory"
                    case reality = "reality"
                    case periodicity = "periodicity"
                    case trigger = "trigger"
                }

                                public let theory: Bool

                                public let reality: Bool

                public let periodicity: Periodicity?

                public let trigger: Trigger?

                public init(theory: Bool, reality: Bool, periodicity: Periodicity? = nil, trigger: Trigger? = nil) {
                    self.theory = theory
                    self.reality = reality
                    self.periodicity = periodicity
                    self.trigger = trigger
                }
            }

            public init(autoRenewInfo: AutoRenewInfo, hasInvoices: Bool, billingInformation: PremiumGetSubscriptionInfoBillingInformation? = nil) {
                self.autoRenewInfo = autoRenewInfo
                self.hasInvoices = hasInvoices
                self.billingInformation = billingInformation
            }
        }

                public struct B2bSubscription: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case hasInvoices = "hasInvoices"
                case billingInformation = "billingInformation"
                case vatNumber = "vatNumber"
            }

                        public let hasInvoices: Bool

            public let billingInformation: PremiumGetSubscriptionInfoBillingInformation?

                        public let vatNumber: Int?

            public init(hasInvoices: Bool, billingInformation: PremiumGetSubscriptionInfoBillingInformation? = nil, vatNumber: Int? = nil) {
                self.hasInvoices = hasInvoices
                self.billingInformation = billingInformation
                self.vatNumber = vatNumber
            }
        }

        public init(b2cSubscription: B2cSubscription, b2bSubscription: B2bSubscription? = nil) {
            self.b2cSubscription = b2cSubscription
            self.b2bSubscription = b2bSubscription
        }
    }
}
