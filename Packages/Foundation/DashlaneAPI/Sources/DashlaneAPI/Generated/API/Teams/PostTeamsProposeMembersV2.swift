import Foundation

extension UserDeviceAPIClient.Teams {
  public struct ProposeMembersV2: APIRequest {
    public static let endpoint: Endpoint = "/teams/ProposeMembersV2"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      proposedMemberLogins: [String], force: Bool? = nil,
      notificationOptions: Body.NotificationOptions? = nil, origin: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        proposedMemberLogins: proposedMemberLogins, force: force,
        notificationOptions: notificationOptions, origin: origin)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var proposeMembersV2: ProposeMembersV2 {
    ProposeMembersV2(api: api)
  }
}

extension UserDeviceAPIClient.Teams.ProposeMembersV2 {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case proposedMemberLogins = "proposedMemberLogins"
      case force = "force"
      case notificationOptions = "notificationOptions"
      case origin = "origin"
    }

    public struct NotificationOptions: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case senderEmail = "senderEmail"
        case skipAccountCreationRequiredAlerts = "skipAccountCreationRequiredAlerts"
        case skipProposals = "skipProposals"
        case skipRemovals = "skipRemovals"
        case skipReproposals = "skipReproposals"
      }

      public let senderEmail: String?
      public let skipAccountCreationRequiredAlerts: Bool?
      public let skipProposals: Bool?
      public let skipRemovals: Bool?
      public let skipReproposals: Bool?

      public init(
        senderEmail: String? = nil, skipAccountCreationRequiredAlerts: Bool? = nil,
        skipProposals: Bool? = nil, skipRemovals: Bool? = nil, skipReproposals: Bool? = nil
      ) {
        self.senderEmail = senderEmail
        self.skipAccountCreationRequiredAlerts = skipAccountCreationRequiredAlerts
        self.skipProposals = skipProposals
        self.skipRemovals = skipRemovals
        self.skipReproposals = skipReproposals
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(senderEmail, forKey: .senderEmail)
        try container.encodeIfPresent(
          skipAccountCreationRequiredAlerts, forKey: .skipAccountCreationRequiredAlerts)
        try container.encodeIfPresent(skipProposals, forKey: .skipProposals)
        try container.encodeIfPresent(skipRemovals, forKey: .skipRemovals)
        try container.encodeIfPresent(skipReproposals, forKey: .skipReproposals)
      }
    }

    public let proposedMemberLogins: [String]
    public let force: Bool?
    public let notificationOptions: NotificationOptions?
    public let origin: String?

    public init(
      proposedMemberLogins: [String], force: Bool? = nil,
      notificationOptions: NotificationOptions? = nil, origin: String? = nil
    ) {
      self.proposedMemberLogins = proposedMemberLogins
      self.force = force
      self.notificationOptions = notificationOptions
      self.origin = origin
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(proposedMemberLogins, forKey: .proposedMemberLogins)
      try container.encodeIfPresent(force, forKey: .force)
      try container.encodeIfPresent(notificationOptions, forKey: .notificationOptions)
      try container.encodeIfPresent(origin, forKey: .origin)
    }
  }
}

extension UserDeviceAPIClient.Teams.ProposeMembersV2 {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case team = "team"
      case proposedMembers = "proposedMembers"
      case refusedMembers = "refusedMembers"
      case accountCreationRequiredMembers = "accountCreationRequiredMembers"
    }

    public struct Team: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case membersNumber = "membersNumber"
        case extraFreeSlots = "extraFreeSlots"
        case statusCode = "statusCode"
        case teamPaymentLogs = "teamPaymentLogs"
        case creationDateUnix = "creationDateUnix"
        case planId = "planId"
        case planType = "planType"
        case planTier = "planTier"
        case planDetails = "planDetails"
        case assignedPlanDetails = "assignedPlanDetails"
        case usersToBeRenewedCount = "usersToBeRenewedCount"
        case info = "info"
        case lastBillingDateUnix = "lastBillingDateUnix"
        case isFreeTrial = "isFreeTrial"
        case isGracePeriod = "isGracePeriod"
        case isExpiringSoon = "isExpiringSoon"
        case remainingSlots = "remainingSlots"
        case creationOrigin = "creationOrigin"
        case currentBillingInfoLite = "currentBillingInfoLite"
        case isRenewalStopped = "isRenewalStopped"
        case isTestTeam = "isTestTeam"
        case members = "members"
        case nextBillingDetails = "nextBillingDetails"
        case securityIndex = "securityIndex"
        case teamId = "teamId"
        case teamUuid = "teamUuid"
      }

      public struct TeamPaymentLogsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case id = "id"
          case eventDateUnix = "eventDateUnix"
          case type = "type"
          case userId = "userId"
          case startDateUnix = "startDateUnix"
          case plan = "plan"
          case cancelled = "cancelled"
          case duration = "duration"
          case familyId = "familyId"
          case membersNumberChange = "membersNumberChange"
          case paymentDetails = "paymentDetails"
          case paymentMadeId = "paymentMadeId"
          case paymentMeanId = "paymentMeanId"
          case paymentMethodDetails = "paymentMethodDetails"
          case planId = "planId"
          case refundedMembersNumber = "refundedMembersNumber"
          case relatedLogId = "relatedLogId"
          case teamId = "teamId"
        }

        public struct Plan: Codable, Equatable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case priceRanges = "priceRanges"
            case id = "id"
            case name = "name"
            case duration = "duration"
            case durationInMonths = "durationInMonths"
            case maxRenewals = "maxRenewals"
            case nextPlan = "nextPlan"
            case type = "type"
            case nbLicenses = "nbLicenses"
            case pricingAlgorithm = "pricingAlgorithm"
            case tier = "tier"
            case isSiteLicense = "isSiteLicense"
            case siteLicenseFullPrice = "siteLicenseFullPrice"
          }

          public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
            case freeTrial = "free_trial"
            case stripe = "stripe"
            case offer = "offer"
            case invoice = "invoice"
            case undecodable
            public init(from decoder: Decoder) throws {
              let container = try decoder.singleValueContainer()
              let rawValue = try container.decode(String.self)
              self = Self(rawValue: rawValue) ?? .undecodable
            }
          }

          public let priceRanges: [TeamsProposeMembersV2PriceRanges]
          public let id: Int
          public let name: String
          public let duration: String
          public let durationInMonths: Int
          public let maxRenewals: Int?
          public let nextPlan: String?
          public let type: `Type`
          public let nbLicenses: Int?
          public let pricingAlgorithm: Int
          public let tier: TeamsProposeMembersV2Tier
          public let isSiteLicense: Bool?
          public let siteLicenseFullPrice: Int?

          public init(
            priceRanges: [TeamsProposeMembersV2PriceRanges], id: Int, name: String,
            duration: String, durationInMonths: Int, maxRenewals: Int?, nextPlan: String?,
            type: `Type`, nbLicenses: Int?, pricingAlgorithm: Int, tier: TeamsProposeMembersV2Tier,
            isSiteLicense: Bool? = nil, siteLicenseFullPrice: Int? = nil
          ) {
            self.priceRanges = priceRanges
            self.id = id
            self.name = name
            self.duration = duration
            self.durationInMonths = durationInMonths
            self.maxRenewals = maxRenewals
            self.nextPlan = nextPlan
            self.type = type
            self.nbLicenses = nbLicenses
            self.pricingAlgorithm = pricingAlgorithm
            self.tier = tier
            self.isSiteLicense = isSiteLicense
            self.siteLicenseFullPrice = siteLicenseFullPrice
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(priceRanges, forKey: .priceRanges)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(duration, forKey: .duration)
            try container.encode(durationInMonths, forKey: .durationInMonths)
            try container.encode(maxRenewals, forKey: .maxRenewals)
            try container.encode(nextPlan, forKey: .nextPlan)
            try container.encode(type, forKey: .type)
            try container.encode(nbLicenses, forKey: .nbLicenses)
            try container.encode(pricingAlgorithm, forKey: .pricingAlgorithm)
            try container.encode(tier, forKey: .tier)
            try container.encodeIfPresent(isSiteLicense, forKey: .isSiteLicense)
            try container.encodeIfPresent(siteLicenseFullPrice, forKey: .siteLicenseFullPrice)
          }
        }

        public struct PaymentDetails: Codable, Equatable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case id = "id"
            case dateUnix = "dateUnix"
            case amount = "amount"
            case currency = "currency"
            case fees = "fees"
            case credit = "credit"
            case externalId = "externalId"
            case invoiceId = "invoiceId"
            case logId = "logId"
            case refundedAmount = "refundedAmount"
            case refundedTaxes = "refundedTaxes"
            case relatedPaymentMadeId = "relatedPaymentMadeId"
            case taxes = "taxes"
          }

          public let id: Int
          public let dateUnix: Int
          public let amount: Int
          public let currency: String
          public let fees: Int?
          public let credit: Bool
          public let externalId: String?
          public let invoiceId: Int?
          public let logId: Int?
          public let refundedAmount: Int?
          public let refundedTaxes: Int?
          public let relatedPaymentMadeId: Int?
          public let taxes: Int?

          public init(
            id: Int, dateUnix: Int, amount: Int, currency: String, fees: Int?, credit: Bool,
            externalId: String?, invoiceId: Int? = nil, logId: Int? = nil,
            refundedAmount: Int? = nil, refundedTaxes: Int? = nil, relatedPaymentMadeId: Int? = nil,
            taxes: Int? = nil
          ) {
            self.id = id
            self.dateUnix = dateUnix
            self.amount = amount
            self.currency = currency
            self.fees = fees
            self.credit = credit
            self.externalId = externalId
            self.invoiceId = invoiceId
            self.logId = logId
            self.refundedAmount = refundedAmount
            self.refundedTaxes = refundedTaxes
            self.relatedPaymentMadeId = relatedPaymentMadeId
            self.taxes = taxes
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(dateUnix, forKey: .dateUnix)
            try container.encode(amount, forKey: .amount)
            try container.encode(currency, forKey: .currency)
            try container.encode(fees, forKey: .fees)
            try container.encode(credit, forKey: .credit)
            try container.encode(externalId, forKey: .externalId)
            try container.encodeIfPresent(invoiceId, forKey: .invoiceId)
            try container.encodeIfPresent(logId, forKey: .logId)
            try container.encodeIfPresent(refundedAmount, forKey: .refundedAmount)
            try container.encodeIfPresent(refundedTaxes, forKey: .refundedTaxes)
            try container.encodeIfPresent(relatedPaymentMadeId, forKey: .relatedPaymentMadeId)
            try container.encodeIfPresent(taxes, forKey: .taxes)
          }
        }

        public struct PaymentMethodDetails: Codable, Equatable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case id = "id"
            case dateUnix = "dateUnix"
            case externalId = "externalId"
            case externalContent = "externalContent"
            case cardId = "card_id"
            case cardBrand = "card_brand"
            case cardFunding = "card_funding"
            case cardFingerprint = "card_fingerprint"
            case cardCountry = "card_country"
            case cardName = "card_name"
            case cardCvcCheck = "card_cvc_check"
            case cardAddressLine1Check = "card_address_line1_check"
            case cardAddressZipCheck = "card_address_zip_check"
            case cardCustomer = "card_customer"
            case cardAddressLine1 = "card_address_line1"
            case cardAddressLine2 = "card_address_line2"
            case cardAddressCity = "card_address_city"
            case cardAddressState = "card_address_state"
            case cardAddressZip = "card_address_zip"
            case cardAddressCountry = "card_address_country"
            case type = "type"
            case subtype = "subtype"
            case cardLast4 = "card_last4"
            case cardType = "card_type"
            case cardExpMonth = "card_exp_month"
            case cardExpYear = "card_exp_year"
            case canRenew = "canRenew"
            case failed = "failed"
          }

          public enum CardExpMonth: Codable, Equatable, Sendable {
            case string(String)
            case number(Int)

            public var string: String? {
              guard case let .string(value) = self else {
                return nil
              }
              return value
            }

            public var number: Int? {
              guard case let .number(value) = self else {
                return nil
              }
              return value
            }

            public init(from decoder: Decoder) throws {
              do {
                self = .string(try .init(from: decoder))
                return
              } catch {
              }
              do {
                self = .number(try .init(from: decoder))
                return
              } catch {
              }
              let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No enum case can be decoded")
              throw DecodingError.typeMismatch(Self.self, context)
            }

            public func encode(to encoder: Encoder) throws {
              var container = encoder.singleValueContainer()
              switch self {
              case .string(let value):
                try container.encode(value)
              case .number(let value):
                try container.encode(value)
              }
            }
          }

          public enum CardExpYear: Codable, Equatable, Sendable {
            case string(String)
            case number(Int)

            public var string: String? {
              guard case let .string(value) = self else {
                return nil
              }
              return value
            }

            public var number: Int? {
              guard case let .number(value) = self else {
                return nil
              }
              return value
            }

            public init(from decoder: Decoder) throws {
              do {
                self = .string(try .init(from: decoder))
                return
              } catch {
              }
              do {
                self = .number(try .init(from: decoder))
                return
              } catch {
              }
              let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No enum case can be decoded")
              throw DecodingError.typeMismatch(Self.self, context)
            }

            public func encode(to encoder: Encoder) throws {
              var container = encoder.singleValueContainer()
              switch self {
              case .string(let value):
                try container.encode(value)
              case .number(let value):
                try container.encode(value)
              }
            }
          }

          public let id: Int
          public let dateUnix: Int
          public let externalId: String?
          public let externalContent: String?
          public let cardId: String?
          public let cardBrand: String?
          public let cardFunding: String?
          public let cardFingerprint: String?
          public let cardCountry: String?
          public let cardName: String?
          public let cardCvcCheck: String?
          public let cardAddressLine1Check: String?
          public let cardAddressZipCheck: String?
          public let cardCustomer: String?
          public let cardAddressLine1: String?
          public let cardAddressLine2: String?
          public let cardAddressCity: String?
          public let cardAddressState: String?
          public let cardAddressZip: String?
          public let cardAddressCountry: String?
          public let type: String
          public let subtype: String?
          public let cardLast4: String?
          public let cardType: String?
          public let cardExpMonth: CardExpMonth?
          public let cardExpYear: CardExpYear?
          public let canRenew: Bool?
          public let failed: Bool?

          public init(
            id: Int, dateUnix: Int, externalId: String?, externalContent: String?, cardId: String?,
            cardBrand: String?, cardFunding: String?, cardFingerprint: String?,
            cardCountry: String?, cardName: String?, cardCvcCheck: String?,
            cardAddressLine1Check: String?, cardAddressZipCheck: String?, cardCustomer: String?,
            cardAddressLine1: String?, cardAddressLine2: String?, cardAddressCity: String?,
            cardAddressState: String?, cardAddressZip: String?, cardAddressCountry: String?,
            type: String, subtype: String?, cardLast4: String?, cardType: String?,
            cardExpMonth: CardExpMonth?, cardExpYear: CardExpYear?, canRenew: Bool? = nil,
            failed: Bool? = nil
          ) {
            self.id = id
            self.dateUnix = dateUnix
            self.externalId = externalId
            self.externalContent = externalContent
            self.cardId = cardId
            self.cardBrand = cardBrand
            self.cardFunding = cardFunding
            self.cardFingerprint = cardFingerprint
            self.cardCountry = cardCountry
            self.cardName = cardName
            self.cardCvcCheck = cardCvcCheck
            self.cardAddressLine1Check = cardAddressLine1Check
            self.cardAddressZipCheck = cardAddressZipCheck
            self.cardCustomer = cardCustomer
            self.cardAddressLine1 = cardAddressLine1
            self.cardAddressLine2 = cardAddressLine2
            self.cardAddressCity = cardAddressCity
            self.cardAddressState = cardAddressState
            self.cardAddressZip = cardAddressZip
            self.cardAddressCountry = cardAddressCountry
            self.type = type
            self.subtype = subtype
            self.cardLast4 = cardLast4
            self.cardType = cardType
            self.cardExpMonth = cardExpMonth
            self.cardExpYear = cardExpYear
            self.canRenew = canRenew
            self.failed = failed
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(dateUnix, forKey: .dateUnix)
            try container.encode(externalId, forKey: .externalId)
            try container.encode(externalContent, forKey: .externalContent)
            try container.encode(cardId, forKey: .cardId)
            try container.encode(cardBrand, forKey: .cardBrand)
            try container.encode(cardFunding, forKey: .cardFunding)
            try container.encode(cardFingerprint, forKey: .cardFingerprint)
            try container.encode(cardCountry, forKey: .cardCountry)
            try container.encode(cardName, forKey: .cardName)
            try container.encode(cardCvcCheck, forKey: .cardCvcCheck)
            try container.encode(cardAddressLine1Check, forKey: .cardAddressLine1Check)
            try container.encode(cardAddressZipCheck, forKey: .cardAddressZipCheck)
            try container.encode(cardCustomer, forKey: .cardCustomer)
            try container.encode(cardAddressLine1, forKey: .cardAddressLine1)
            try container.encode(cardAddressLine2, forKey: .cardAddressLine2)
            try container.encode(cardAddressCity, forKey: .cardAddressCity)
            try container.encode(cardAddressState, forKey: .cardAddressState)
            try container.encode(cardAddressZip, forKey: .cardAddressZip)
            try container.encode(cardAddressCountry, forKey: .cardAddressCountry)
            try container.encode(type, forKey: .type)
            try container.encode(subtype, forKey: .subtype)
            try container.encode(cardLast4, forKey: .cardLast4)
            try container.encode(cardType, forKey: .cardType)
            try container.encode(cardExpMonth, forKey: .cardExpMonth)
            try container.encode(cardExpYear, forKey: .cardExpYear)
            try container.encodeIfPresent(canRenew, forKey: .canRenew)
            try container.encodeIfPresent(failed, forKey: .failed)
          }
        }

        public let id: Int
        public let eventDateUnix: Int
        public let type: String
        public let userId: Int?
        public let startDateUnix: Int?
        public let plan: Plan?
        public let cancelled: Bool?
        public let duration: String?
        public let familyId: Int?
        public let membersNumberChange: Int?
        public let paymentDetails: PaymentDetails?
        public let paymentMadeId: Int?
        public let paymentMeanId: Int?
        public let paymentMethodDetails: PaymentMethodDetails?
        public let planId: String?
        public let refundedMembersNumber: Int?
        public let relatedLogId: Int?
        public let teamId: Int?

        public init(
          id: Int, eventDateUnix: Int, type: String, userId: Int?, startDateUnix: Int?, plan: Plan?,
          cancelled: Bool? = nil, duration: String? = nil, familyId: Int? = nil,
          membersNumberChange: Int? = nil, paymentDetails: PaymentDetails? = nil,
          paymentMadeId: Int? = nil, paymentMeanId: Int? = nil,
          paymentMethodDetails: PaymentMethodDetails? = nil, planId: String? = nil,
          refundedMembersNumber: Int? = nil, relatedLogId: Int? = nil, teamId: Int? = nil
        ) {
          self.id = id
          self.eventDateUnix = eventDateUnix
          self.type = type
          self.userId = userId
          self.startDateUnix = startDateUnix
          self.plan = plan
          self.cancelled = cancelled
          self.duration = duration
          self.familyId = familyId
          self.membersNumberChange = membersNumberChange
          self.paymentDetails = paymentDetails
          self.paymentMadeId = paymentMadeId
          self.paymentMeanId = paymentMeanId
          self.paymentMethodDetails = paymentMethodDetails
          self.planId = planId
          self.refundedMembersNumber = refundedMembersNumber
          self.relatedLogId = relatedLogId
          self.teamId = teamId
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id, forKey: .id)
          try container.encode(eventDateUnix, forKey: .eventDateUnix)
          try container.encode(type, forKey: .type)
          try container.encode(userId, forKey: .userId)
          try container.encode(startDateUnix, forKey: .startDateUnix)
          try container.encode(plan, forKey: .plan)
          try container.encodeIfPresent(cancelled, forKey: .cancelled)
          try container.encodeIfPresent(duration, forKey: .duration)
          try container.encodeIfPresent(familyId, forKey: .familyId)
          try container.encodeIfPresent(membersNumberChange, forKey: .membersNumberChange)
          try container.encodeIfPresent(paymentDetails, forKey: .paymentDetails)
          try container.encodeIfPresent(paymentMadeId, forKey: .paymentMadeId)
          try container.encodeIfPresent(paymentMeanId, forKey: .paymentMeanId)
          try container.encodeIfPresent(paymentMethodDetails, forKey: .paymentMethodDetails)
          try container.encodeIfPresent(planId, forKey: .planId)
          try container.encodeIfPresent(refundedMembersNumber, forKey: .refundedMembersNumber)
          try container.encodeIfPresent(relatedLogId, forKey: .relatedLogId)
          try container.encodeIfPresent(teamId, forKey: .teamId)
        }
      }

      public struct Info: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case activeDirectoryAllowedIpRange = "activeDirectoryAllowedIpRange"
          case activeDirectorySyncType = "activeDirectorySyncType"
          case activeDirectoryToken = "activeDirectoryToken"
          case autologinDomainDisabledArray = "autologinDomainDisabledArray"
          case collectSensitiveDataAuditLogsEnabled = "collectSensitiveDataAuditLogsEnabled"
          case cryptoForcedPayload = "cryptoForcedPayload"
          case defaultCurrency = "defaultCurrency"
          case distributor = "distributor"
          case duo = "duo"
          case duoApiHostname = "duoApiHostname"
          case duoIntegrationKey = "duoIntegrationKey"
          case duoSecretKey = "duoSecretKey"
          case emergencyDisabled = "emergencyDisabled"
          case features = "features"
          case forceAutomaticLogout = "forceAutomaticLogout"
          case forcedDomainsEnabled = "forcedDomainsEnabled"
          case freeFamilyProvisioningEnabled = "freeFamilyProvisioningEnabled"
          case fullSeatCountRenewal = "fullSeatCountRenewal"
          case gracePeriodDuration = "gracePeriodDuration"
          case groupManagers = "groupManagers"
          case idpCertificate = "idpCertificate"
          case idpSecurityGroups = "idpSecurityGroups"
          case idpUrl = "idpUrl"
          case lockOnExit = "lockOnExit"
          case mailVersion = "mailVersion"
          case mpEnforcePolicy = "mpEnforcePolicy"
          case mpPersistenceDisabled = "mpPersistenceDisabled"
          case mpPolicyMinDigits = "mpPolicyMinDigits"
          case mpPolicyMinLength = "mpPolicyMinLength"
          case mpPolicyMinLowerCase = "mpPolicyMinLowerCase"
          case mpPolicyMinSpecials = "mpPolicyMinSpecials"
          case mpPolicyMinUpperCase = "mpPolicyMinUpperCase"
          case name = "name"
          case personalSpaceEnabled = "personalSpaceEnabled"
          case recoveryEnabled = "recoveryEnabled"
          case removalGracePeriodPlan = "removalGracePeriodPlan"
          case removeForcedContentEnabled = "removeForcedContentEnabled"
          case richIconsEnabled = "richIconsEnabled"
          case secureStorageEnabled = "secureStorageEnabled"
          case secureWifiEnabled = "secureWifiEnabled"
          case sharingDisabled = "sharingDisabled"
          case sharingRestrictedToTeam = "sharingRestrictedToTeam"
          case spaceRestrictionsEnabled = "spaceRestrictionsEnabled"
          case ssoActivationType = "ssoActivationType"
          case ssoEnabled = "ssoEnabled"
          case ssoIdpEntrypoint = "ssoIdpEntrypoint"
          case ssoIdpMetadata = "ssoIdpMetadata"
          case ssoIsNitroProvider = "ssoIsNitroProvider"
          case ssoProvisioning = "ssoProvisioning"
          case ssoServiceProviderUrl = "ssoServiceProviderUrl"
          case teamCaptains = "teamCaptains"
          case teamDomains = "teamDomains"
          case teamSignupPageEnabled = "teamSignupPageEnabled"
          case twoFAEnforced = "twoFAEnforced"
          case vaultExportEnabled = "vaultExportEnabled"
          case whoCanShareCollections = "whoCanShareCollections"
        }

        public let activeDirectoryAllowedIpRange: String?
        public let activeDirectorySyncType: String?
        public let activeDirectoryToken: String?
        public let autologinDomainDisabledArray: [String]?
        public let collectSensitiveDataAuditLogsEnabled: Bool?
        public let cryptoForcedPayload: String?
        public let defaultCurrency: String?
        public let distributor: String?
        public let duo: Bool?
        public let duoApiHostname: String?
        public let duoIntegrationKey: String?
        public let duoSecretKey: String?
        public let emergencyDisabled: Bool?
        public let features: [String: Bool]?
        public let forceAutomaticLogout: Int?
        public let forcedDomainsEnabled: Bool?
        public let freeFamilyProvisioningEnabled: Bool?
        public let fullSeatCountRenewal: Bool?
        public let gracePeriodDuration: String?
        public let groupManagers: [Int]?
        public let idpCertificate: String?
        public let idpSecurityGroups: [String]?
        public let idpUrl: String?
        public let lockOnExit: Bool?
        public let mailVersion: String?
        public let mpEnforcePolicy: Bool?
        public let mpPersistenceDisabled: Bool?
        public let mpPolicyMinDigits: Int?
        public let mpPolicyMinLength: Int?
        public let mpPolicyMinLowerCase: Int?
        public let mpPolicyMinSpecials: Int?
        public let mpPolicyMinUpperCase: Int?
        public let name: String?
        public let personalSpaceEnabled: Bool?
        public let recoveryEnabled: Bool?
        public let removalGracePeriodPlan: String?
        public let removeForcedContentEnabled: Bool?
        public let richIconsEnabled: Bool?
        public let secureStorageEnabled: Bool?
        public let secureWifiEnabled: Bool?
        public let sharingDisabled: Bool?
        public let sharingRestrictedToTeam: Bool?
        public let spaceRestrictionsEnabled: Bool?
        public let ssoActivationType: String?
        public let ssoEnabled: Bool?
        public let ssoIdpEntrypoint: String?
        public let ssoIdpMetadata: String?
        public let ssoIsNitroProvider: Bool?
        public let ssoProvisioning: String?
        public let ssoServiceProviderUrl: String?
        public let teamCaptains: [String: Bool]?
        public let teamDomains: [String]?
        public let teamSignupPageEnabled: Bool?
        public let twoFAEnforced: String?
        public let vaultExportEnabled: Bool?
        public let whoCanShareCollections: String?

        public init(
          activeDirectoryAllowedIpRange: String? = nil, activeDirectorySyncType: String? = nil,
          activeDirectoryToken: String? = nil, autologinDomainDisabledArray: [String]? = nil,
          collectSensitiveDataAuditLogsEnabled: Bool? = nil, cryptoForcedPayload: String? = nil,
          defaultCurrency: String? = nil, distributor: String? = nil, duo: Bool? = nil,
          duoApiHostname: String? = nil, duoIntegrationKey: String? = nil,
          duoSecretKey: String? = nil, emergencyDisabled: Bool? = nil,
          features: [String: Bool]? = nil, forceAutomaticLogout: Int? = nil,
          forcedDomainsEnabled: Bool? = nil, freeFamilyProvisioningEnabled: Bool? = nil,
          fullSeatCountRenewal: Bool? = nil, gracePeriodDuration: String? = nil,
          groupManagers: [Int]? = nil, idpCertificate: String? = nil,
          idpSecurityGroups: [String]? = nil, idpUrl: String? = nil, lockOnExit: Bool? = nil,
          mailVersion: String? = nil, mpEnforcePolicy: Bool? = nil,
          mpPersistenceDisabled: Bool? = nil, mpPolicyMinDigits: Int? = nil,
          mpPolicyMinLength: Int? = nil, mpPolicyMinLowerCase: Int? = nil,
          mpPolicyMinSpecials: Int? = nil, mpPolicyMinUpperCase: Int? = nil, name: String? = nil,
          personalSpaceEnabled: Bool? = nil, recoveryEnabled: Bool? = nil,
          removalGracePeriodPlan: String? = nil, removeForcedContentEnabled: Bool? = nil,
          richIconsEnabled: Bool? = nil, secureStorageEnabled: Bool? = nil,
          secureWifiEnabled: Bool? = nil, sharingDisabled: Bool? = nil,
          sharingRestrictedToTeam: Bool? = nil, spaceRestrictionsEnabled: Bool? = nil,
          ssoActivationType: String? = nil, ssoEnabled: Bool? = nil,
          ssoIdpEntrypoint: String? = nil, ssoIdpMetadata: String? = nil,
          ssoIsNitroProvider: Bool? = nil, ssoProvisioning: String? = nil,
          ssoServiceProviderUrl: String? = nil, teamCaptains: [String: Bool]? = nil,
          teamDomains: [String]? = nil, teamSignupPageEnabled: Bool? = nil,
          twoFAEnforced: String? = nil, vaultExportEnabled: Bool? = nil,
          whoCanShareCollections: String? = nil
        ) {
          self.activeDirectoryAllowedIpRange = activeDirectoryAllowedIpRange
          self.activeDirectorySyncType = activeDirectorySyncType
          self.activeDirectoryToken = activeDirectoryToken
          self.autologinDomainDisabledArray = autologinDomainDisabledArray
          self.collectSensitiveDataAuditLogsEnabled = collectSensitiveDataAuditLogsEnabled
          self.cryptoForcedPayload = cryptoForcedPayload
          self.defaultCurrency = defaultCurrency
          self.distributor = distributor
          self.duo = duo
          self.duoApiHostname = duoApiHostname
          self.duoIntegrationKey = duoIntegrationKey
          self.duoSecretKey = duoSecretKey
          self.emergencyDisabled = emergencyDisabled
          self.features = features
          self.forceAutomaticLogout = forceAutomaticLogout
          self.forcedDomainsEnabled = forcedDomainsEnabled
          self.freeFamilyProvisioningEnabled = freeFamilyProvisioningEnabled
          self.fullSeatCountRenewal = fullSeatCountRenewal
          self.gracePeriodDuration = gracePeriodDuration
          self.groupManagers = groupManagers
          self.idpCertificate = idpCertificate
          self.idpSecurityGroups = idpSecurityGroups
          self.idpUrl = idpUrl
          self.lockOnExit = lockOnExit
          self.mailVersion = mailVersion
          self.mpEnforcePolicy = mpEnforcePolicy
          self.mpPersistenceDisabled = mpPersistenceDisabled
          self.mpPolicyMinDigits = mpPolicyMinDigits
          self.mpPolicyMinLength = mpPolicyMinLength
          self.mpPolicyMinLowerCase = mpPolicyMinLowerCase
          self.mpPolicyMinSpecials = mpPolicyMinSpecials
          self.mpPolicyMinUpperCase = mpPolicyMinUpperCase
          self.name = name
          self.personalSpaceEnabled = personalSpaceEnabled
          self.recoveryEnabled = recoveryEnabled
          self.removalGracePeriodPlan = removalGracePeriodPlan
          self.removeForcedContentEnabled = removeForcedContentEnabled
          self.richIconsEnabled = richIconsEnabled
          self.secureStorageEnabled = secureStorageEnabled
          self.secureWifiEnabled = secureWifiEnabled
          self.sharingDisabled = sharingDisabled
          self.sharingRestrictedToTeam = sharingRestrictedToTeam
          self.spaceRestrictionsEnabled = spaceRestrictionsEnabled
          self.ssoActivationType = ssoActivationType
          self.ssoEnabled = ssoEnabled
          self.ssoIdpEntrypoint = ssoIdpEntrypoint
          self.ssoIdpMetadata = ssoIdpMetadata
          self.ssoIsNitroProvider = ssoIsNitroProvider
          self.ssoProvisioning = ssoProvisioning
          self.ssoServiceProviderUrl = ssoServiceProviderUrl
          self.teamCaptains = teamCaptains
          self.teamDomains = teamDomains
          self.teamSignupPageEnabled = teamSignupPageEnabled
          self.twoFAEnforced = twoFAEnforced
          self.vaultExportEnabled = vaultExportEnabled
          self.whoCanShareCollections = whoCanShareCollections
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(
            activeDirectoryAllowedIpRange, forKey: .activeDirectoryAllowedIpRange)
          try container.encodeIfPresent(activeDirectorySyncType, forKey: .activeDirectorySyncType)
          try container.encodeIfPresent(activeDirectoryToken, forKey: .activeDirectoryToken)
          try container.encodeIfPresent(
            autologinDomainDisabledArray, forKey: .autologinDomainDisabledArray)
          try container.encodeIfPresent(
            collectSensitiveDataAuditLogsEnabled, forKey: .collectSensitiveDataAuditLogsEnabled)
          try container.encodeIfPresent(cryptoForcedPayload, forKey: .cryptoForcedPayload)
          try container.encodeIfPresent(defaultCurrency, forKey: .defaultCurrency)
          try container.encodeIfPresent(distributor, forKey: .distributor)
          try container.encodeIfPresent(duo, forKey: .duo)
          try container.encodeIfPresent(duoApiHostname, forKey: .duoApiHostname)
          try container.encodeIfPresent(duoIntegrationKey, forKey: .duoIntegrationKey)
          try container.encodeIfPresent(duoSecretKey, forKey: .duoSecretKey)
          try container.encodeIfPresent(emergencyDisabled, forKey: .emergencyDisabled)
          try container.encodeIfPresent(features, forKey: .features)
          try container.encodeIfPresent(forceAutomaticLogout, forKey: .forceAutomaticLogout)
          try container.encodeIfPresent(forcedDomainsEnabled, forKey: .forcedDomainsEnabled)
          try container.encodeIfPresent(
            freeFamilyProvisioningEnabled, forKey: .freeFamilyProvisioningEnabled)
          try container.encodeIfPresent(fullSeatCountRenewal, forKey: .fullSeatCountRenewal)
          try container.encodeIfPresent(gracePeriodDuration, forKey: .gracePeriodDuration)
          try container.encodeIfPresent(groupManagers, forKey: .groupManagers)
          try container.encodeIfPresent(idpCertificate, forKey: .idpCertificate)
          try container.encodeIfPresent(idpSecurityGroups, forKey: .idpSecurityGroups)
          try container.encodeIfPresent(idpUrl, forKey: .idpUrl)
          try container.encodeIfPresent(lockOnExit, forKey: .lockOnExit)
          try container.encodeIfPresent(mailVersion, forKey: .mailVersion)
          try container.encodeIfPresent(mpEnforcePolicy, forKey: .mpEnforcePolicy)
          try container.encodeIfPresent(mpPersistenceDisabled, forKey: .mpPersistenceDisabled)
          try container.encodeIfPresent(mpPolicyMinDigits, forKey: .mpPolicyMinDigits)
          try container.encodeIfPresent(mpPolicyMinLength, forKey: .mpPolicyMinLength)
          try container.encodeIfPresent(mpPolicyMinLowerCase, forKey: .mpPolicyMinLowerCase)
          try container.encodeIfPresent(mpPolicyMinSpecials, forKey: .mpPolicyMinSpecials)
          try container.encodeIfPresent(mpPolicyMinUpperCase, forKey: .mpPolicyMinUpperCase)
          try container.encodeIfPresent(name, forKey: .name)
          try container.encodeIfPresent(personalSpaceEnabled, forKey: .personalSpaceEnabled)
          try container.encodeIfPresent(recoveryEnabled, forKey: .recoveryEnabled)
          try container.encodeIfPresent(removalGracePeriodPlan, forKey: .removalGracePeriodPlan)
          try container.encodeIfPresent(
            removeForcedContentEnabled, forKey: .removeForcedContentEnabled)
          try container.encodeIfPresent(richIconsEnabled, forKey: .richIconsEnabled)
          try container.encodeIfPresent(secureStorageEnabled, forKey: .secureStorageEnabled)
          try container.encodeIfPresent(secureWifiEnabled, forKey: .secureWifiEnabled)
          try container.encodeIfPresent(sharingDisabled, forKey: .sharingDisabled)
          try container.encodeIfPresent(sharingRestrictedToTeam, forKey: .sharingRestrictedToTeam)
          try container.encodeIfPresent(spaceRestrictionsEnabled, forKey: .spaceRestrictionsEnabled)
          try container.encodeIfPresent(ssoActivationType, forKey: .ssoActivationType)
          try container.encodeIfPresent(ssoEnabled, forKey: .ssoEnabled)
          try container.encodeIfPresent(ssoIdpEntrypoint, forKey: .ssoIdpEntrypoint)
          try container.encodeIfPresent(ssoIdpMetadata, forKey: .ssoIdpMetadata)
          try container.encodeIfPresent(ssoIsNitroProvider, forKey: .ssoIsNitroProvider)
          try container.encodeIfPresent(ssoProvisioning, forKey: .ssoProvisioning)
          try container.encodeIfPresent(ssoServiceProviderUrl, forKey: .ssoServiceProviderUrl)
          try container.encodeIfPresent(teamCaptains, forKey: .teamCaptains)
          try container.encodeIfPresent(teamDomains, forKey: .teamDomains)
          try container.encodeIfPresent(teamSignupPageEnabled, forKey: .teamSignupPageEnabled)
          try container.encodeIfPresent(twoFAEnforced, forKey: .twoFAEnforced)
          try container.encodeIfPresent(vaultExportEnabled, forKey: .vaultExportEnabled)
          try container.encodeIfPresent(whoCanShareCollections, forKey: .whoCanShareCollections)
        }
      }

      public struct CurrentBillingInfoLite: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case cardAddressLine1 = "card_address_line1"
          case cardAddressLine2 = "card_address_line2"
          case cardAddressCity = "card_address_city"
          case cardAddressState = "card_address_state"
          case cardAddressZip = "card_address_zip"
          case cardAddressCountry = "card_address_country"
          case type = "type"
          case subtype = "subtype"
          case cardLast4 = "card_last4"
          case cardType = "card_type"
          case cardExpMonth = "card_exp_month"
          case cardExpYear = "card_exp_year"
          case externalId = "externalId"
        }

        public enum CardExpMonth: Codable, Equatable, Sendable {
          case string(String)
          case number(Int)

          public var string: String? {
            guard case let .string(value) = self else {
              return nil
            }
            return value
          }

          public var number: Int? {
            guard case let .number(value) = self else {
              return nil
            }
            return value
          }

          public init(from decoder: Decoder) throws {
            do {
              self = .string(try .init(from: decoder))
              return
            } catch {
            }
            do {
              self = .number(try .init(from: decoder))
              return
            } catch {
            }
            let context = DecodingError.Context(
              codingPath: decoder.codingPath,
              debugDescription: "No enum case can be decoded")
            throw DecodingError.typeMismatch(Self.self, context)
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
              try container.encode(value)
            case .number(let value):
              try container.encode(value)
            }
          }
        }

        public enum CardExpYear: Codable, Equatable, Sendable {
          case string(String)
          case number(Int)

          public var string: String? {
            guard case let .string(value) = self else {
              return nil
            }
            return value
          }

          public var number: Int? {
            guard case let .number(value) = self else {
              return nil
            }
            return value
          }

          public init(from decoder: Decoder) throws {
            do {
              self = .string(try .init(from: decoder))
              return
            } catch {
            }
            do {
              self = .number(try .init(from: decoder))
              return
            } catch {
            }
            let context = DecodingError.Context(
              codingPath: decoder.codingPath,
              debugDescription: "No enum case can be decoded")
            throw DecodingError.typeMismatch(Self.self, context)
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
              try container.encode(value)
            case .number(let value):
              try container.encode(value)
            }
          }
        }

        public let cardAddressLine1: String?
        public let cardAddressLine2: String?
        public let cardAddressCity: String?
        public let cardAddressState: String?
        public let cardAddressZip: String?
        public let cardAddressCountry: String?
        public let type: String
        public let subtype: String?
        public let cardLast4: String?
        public let cardType: String?
        public let cardExpMonth: CardExpMonth?
        public let cardExpYear: CardExpYear?
        public let externalId: String?

        public init(
          cardAddressLine1: String?, cardAddressLine2: String?, cardAddressCity: String?,
          cardAddressState: String?, cardAddressZip: String?, cardAddressCountry: String?,
          type: String, subtype: String?, cardLast4: String?, cardType: String?,
          cardExpMonth: CardExpMonth?, cardExpYear: CardExpYear?, externalId: String? = nil
        ) {
          self.cardAddressLine1 = cardAddressLine1
          self.cardAddressLine2 = cardAddressLine2
          self.cardAddressCity = cardAddressCity
          self.cardAddressState = cardAddressState
          self.cardAddressZip = cardAddressZip
          self.cardAddressCountry = cardAddressCountry
          self.type = type
          self.subtype = subtype
          self.cardLast4 = cardLast4
          self.cardType = cardType
          self.cardExpMonth = cardExpMonth
          self.cardExpYear = cardExpYear
          self.externalId = externalId
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(cardAddressLine1, forKey: .cardAddressLine1)
          try container.encode(cardAddressLine2, forKey: .cardAddressLine2)
          try container.encode(cardAddressCity, forKey: .cardAddressCity)
          try container.encode(cardAddressState, forKey: .cardAddressState)
          try container.encode(cardAddressZip, forKey: .cardAddressZip)
          try container.encode(cardAddressCountry, forKey: .cardAddressCountry)
          try container.encode(type, forKey: .type)
          try container.encode(subtype, forKey: .subtype)
          try container.encode(cardLast4, forKey: .cardLast4)
          try container.encode(cardType, forKey: .cardType)
          try container.encode(cardExpMonth, forKey: .cardExpMonth)
          try container.encode(cardExpYear, forKey: .cardExpYear)
          try container.encodeIfPresent(externalId, forKey: .externalId)
        }
      }

      public struct MembersElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case status = "status"
          case login = "login"
          case email = "email"
          case encryptionKeyLastDigits = "encryptionKeyLastDigits"
          case familyPromoLink = "familyPromoLink"
          case hasLatestConfig = "hasLatestConfig"
          case invitedDateUnix = "invitedDateUnix"
          case isAccountCreated = "isAccountCreated"
          case isBillingAdmin = "isBillingAdmin"
          case isTeamCaptain = "isTeamCaptain"
          case joinedDateUnix = "joinedDateUnix"
          case language = "language"
          case lastActivityDateUnix = "lastActivityDateUnix"
          case lastUpdateDateUnix = "lastUpdateDateUnix"
          case name = "name"
          case nbrPasswords = "nbrPasswords"
          case recoveryCreationDateUnix = "recoveryCreationDateUnix"
          case revokedDateUnix = "revokedDateUnix"
          case ssoStatus = "ssoStatus"
          case token = "token"
          case twoFAStatus = "twoFAStatus"
          case userId = "userId"
        }

        public enum SsoStatus: String, Sendable, Equatable, CaseIterable, Codable {
          case activated = "activated"
          case pendingActivation = "pending_activation"
          case pendingDeactivation = "pending_deactivation"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public struct Token: Codable, Equatable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case inviterUserId = "inviterUserId"
            case isFresh = "isFresh"
            case lastNotificationDateUnix = "lastNotificationDateUnix"
            case teamId = "teamId"
            case token = "token"
            case userId = "userId"
          }

          public let inviterUserId: Int?
          public let isFresh: Bool?
          public let lastNotificationDateUnix: Int?
          public let teamId: Int?
          public let token: String?
          public let userId: Int?

          public init(
            inviterUserId: Int? = nil, isFresh: Bool? = nil, lastNotificationDateUnix: Int? = nil,
            teamId: Int? = nil, token: String? = nil, userId: Int? = nil
          ) {
            self.inviterUserId = inviterUserId
            self.isFresh = isFresh
            self.lastNotificationDateUnix = lastNotificationDateUnix
            self.teamId = teamId
            self.token = token
            self.userId = userId
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(inviterUserId, forKey: .inviterUserId)
            try container.encodeIfPresent(isFresh, forKey: .isFresh)
            try container.encodeIfPresent(
              lastNotificationDateUnix, forKey: .lastNotificationDateUnix)
            try container.encodeIfPresent(teamId, forKey: .teamId)
            try container.encodeIfPresent(token, forKey: .token)
            try container.encodeIfPresent(userId, forKey: .userId)
          }
        }

        public let status: String
        public let login: String
        public let email: String?
        public let encryptionKeyLastDigits: String?
        public let familyPromoLink: String?
        public let hasLatestConfig: Bool?
        public let invitedDateUnix: Int?
        public let isAccountCreated: Bool?
        public let isBillingAdmin: Bool?
        public let isTeamCaptain: Bool?
        public let joinedDateUnix: Int?
        public let language: String?
        public let lastActivityDateUnix: Int?
        public let lastUpdateDateUnix: Int?
        public let name: String?
        public let nbrPasswords: Int?
        public let recoveryCreationDateUnix: Int?
        public let revokedDateUnix: Int?
        public let ssoStatus: TeamsSsoStatus?
        public let token: Token?
        public let twoFAStatus: Int?
        public let userId: Int?

        public init(
          status: String, login: String, email: String? = nil,
          encryptionKeyLastDigits: String? = nil, familyPromoLink: String? = nil,
          hasLatestConfig: Bool? = nil, invitedDateUnix: Int? = nil, isAccountCreated: Bool? = nil,
          isBillingAdmin: Bool? = nil, isTeamCaptain: Bool? = nil, joinedDateUnix: Int? = nil,
          language: String? = nil, lastActivityDateUnix: Int? = nil, lastUpdateDateUnix: Int? = nil,
          name: String? = nil, nbrPasswords: Int? = nil, recoveryCreationDateUnix: Int? = nil,
          revokedDateUnix: Int? = nil, ssoStatus: TeamsSsoStatus? = nil, token: Token? = nil,
          twoFAStatus: Int? = nil, userId: Int? = nil
        ) {
          self.status = status
          self.login = login
          self.email = email
          self.encryptionKeyLastDigits = encryptionKeyLastDigits
          self.familyPromoLink = familyPromoLink
          self.hasLatestConfig = hasLatestConfig
          self.invitedDateUnix = invitedDateUnix
          self.isAccountCreated = isAccountCreated
          self.isBillingAdmin = isBillingAdmin
          self.isTeamCaptain = isTeamCaptain
          self.joinedDateUnix = joinedDateUnix
          self.language = language
          self.lastActivityDateUnix = lastActivityDateUnix
          self.lastUpdateDateUnix = lastUpdateDateUnix
          self.name = name
          self.nbrPasswords = nbrPasswords
          self.recoveryCreationDateUnix = recoveryCreationDateUnix
          self.revokedDateUnix = revokedDateUnix
          self.ssoStatus = ssoStatus
          self.token = token
          self.twoFAStatus = twoFAStatus
          self.userId = userId
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(status, forKey: .status)
          try container.encode(login, forKey: .login)
          try container.encodeIfPresent(email, forKey: .email)
          try container.encodeIfPresent(encryptionKeyLastDigits, forKey: .encryptionKeyLastDigits)
          try container.encodeIfPresent(familyPromoLink, forKey: .familyPromoLink)
          try container.encodeIfPresent(hasLatestConfig, forKey: .hasLatestConfig)
          try container.encodeIfPresent(invitedDateUnix, forKey: .invitedDateUnix)
          try container.encodeIfPresent(isAccountCreated, forKey: .isAccountCreated)
          try container.encodeIfPresent(isBillingAdmin, forKey: .isBillingAdmin)
          try container.encodeIfPresent(isTeamCaptain, forKey: .isTeamCaptain)
          try container.encodeIfPresent(joinedDateUnix, forKey: .joinedDateUnix)
          try container.encodeIfPresent(language, forKey: .language)
          try container.encodeIfPresent(lastActivityDateUnix, forKey: .lastActivityDateUnix)
          try container.encodeIfPresent(lastUpdateDateUnix, forKey: .lastUpdateDateUnix)
          try container.encodeIfPresent(name, forKey: .name)
          try container.encodeIfPresent(nbrPasswords, forKey: .nbrPasswords)
          try container.encodeIfPresent(recoveryCreationDateUnix, forKey: .recoveryCreationDateUnix)
          try container.encodeIfPresent(revokedDateUnix, forKey: .revokedDateUnix)
          try container.encodeIfPresent(ssoStatus, forKey: .ssoStatus)
          try container.encodeIfPresent(token, forKey: .token)
          try container.encodeIfPresent(twoFAStatus, forKey: .twoFAStatus)
          try container.encodeIfPresent(userId, forKey: .userId)
        }
      }

      public struct NextBillingDetails: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case amount = "amount"
          case currency = "currency"
          case dateUnix = "dateUnix"
        }

        public let amount: Int
        public let currency: String
        public let dateUnix: Int

        public init(amount: Int, currency: String, dateUnix: Int) {
          self.amount = amount
          self.currency = currency
          self.dateUnix = dateUnix
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(amount, forKey: .amount)
          try container.encode(currency, forKey: .currency)
          try container.encode(dateUnix, forKey: .dateUnix)
        }
      }

      public let membersNumber: Int
      public let extraFreeSlots: Int
      public let statusCode: Int
      public let teamPaymentLogs: [TeamPaymentLogsElement]
      public let creationDateUnix: Int
      public let planId: String
      public let planType: String
      public let planTier: TeamsProposeMembersV2Tier
      public let planDetails: TeamsProposeMembersV2PlanDetails
      public let assignedPlanDetails: TeamsProposeMembersV2PlanDetails
      public let usersToBeRenewedCount: Int
      public let info: Info
      public let lastBillingDateUnix: Int
      public let isFreeTrial: Bool
      public let isGracePeriod: Bool
      public let isExpiringSoon: Bool
      public let remainingSlots: Int
      public let creationOrigin: String?
      public let currentBillingInfoLite: CurrentBillingInfoLite?
      public let isRenewalStopped: Bool?
      public let isTestTeam: Bool?
      public let members: [MembersElement]?
      public let nextBillingDetails: NextBillingDetails?
      public let securityIndex: Int?
      public let teamId: Int?
      public let teamUuid: String?

      public init(
        membersNumber: Int, extraFreeSlots: Int, statusCode: Int,
        teamPaymentLogs: [TeamPaymentLogsElement], creationDateUnix: Int, planId: String,
        planType: String, planTier: TeamsProposeMembersV2Tier,
        planDetails: TeamsProposeMembersV2PlanDetails,
        assignedPlanDetails: TeamsProposeMembersV2PlanDetails, usersToBeRenewedCount: Int,
        info: Info, lastBillingDateUnix: Int, isFreeTrial: Bool, isGracePeriod: Bool,
        isExpiringSoon: Bool, remainingSlots: Int, creationOrigin: String? = nil,
        currentBillingInfoLite: CurrentBillingInfoLite? = nil, isRenewalStopped: Bool? = nil,
        isTestTeam: Bool? = nil, members: [MembersElement]? = nil,
        nextBillingDetails: NextBillingDetails? = nil, securityIndex: Int? = nil,
        teamId: Int? = nil, teamUuid: String? = nil
      ) {
        self.membersNumber = membersNumber
        self.extraFreeSlots = extraFreeSlots
        self.statusCode = statusCode
        self.teamPaymentLogs = teamPaymentLogs
        self.creationDateUnix = creationDateUnix
        self.planId = planId
        self.planType = planType
        self.planTier = planTier
        self.planDetails = planDetails
        self.assignedPlanDetails = assignedPlanDetails
        self.usersToBeRenewedCount = usersToBeRenewedCount
        self.info = info
        self.lastBillingDateUnix = lastBillingDateUnix
        self.isFreeTrial = isFreeTrial
        self.isGracePeriod = isGracePeriod
        self.isExpiringSoon = isExpiringSoon
        self.remainingSlots = remainingSlots
        self.creationOrigin = creationOrigin
        self.currentBillingInfoLite = currentBillingInfoLite
        self.isRenewalStopped = isRenewalStopped
        self.isTestTeam = isTestTeam
        self.members = members
        self.nextBillingDetails = nextBillingDetails
        self.securityIndex = securityIndex
        self.teamId = teamId
        self.teamUuid = teamUuid
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(membersNumber, forKey: .membersNumber)
        try container.encode(extraFreeSlots, forKey: .extraFreeSlots)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(teamPaymentLogs, forKey: .teamPaymentLogs)
        try container.encode(creationDateUnix, forKey: .creationDateUnix)
        try container.encode(planId, forKey: .planId)
        try container.encode(planType, forKey: .planType)
        try container.encode(planTier, forKey: .planTier)
        try container.encode(planDetails, forKey: .planDetails)
        try container.encode(assignedPlanDetails, forKey: .assignedPlanDetails)
        try container.encode(usersToBeRenewedCount, forKey: .usersToBeRenewedCount)
        try container.encode(info, forKey: .info)
        try container.encode(lastBillingDateUnix, forKey: .lastBillingDateUnix)
        try container.encode(isFreeTrial, forKey: .isFreeTrial)
        try container.encode(isGracePeriod, forKey: .isGracePeriod)
        try container.encode(isExpiringSoon, forKey: .isExpiringSoon)
        try container.encode(remainingSlots, forKey: .remainingSlots)
        try container.encodeIfPresent(creationOrigin, forKey: .creationOrigin)
        try container.encodeIfPresent(currentBillingInfoLite, forKey: .currentBillingInfoLite)
        try container.encodeIfPresent(isRenewalStopped, forKey: .isRenewalStopped)
        try container.encodeIfPresent(isTestTeam, forKey: .isTestTeam)
        try container.encodeIfPresent(members, forKey: .members)
        try container.encodeIfPresent(nextBillingDetails, forKey: .nextBillingDetails)
        try container.encodeIfPresent(securityIndex, forKey: .securityIndex)
        try container.encodeIfPresent(teamId, forKey: .teamId)
        try container.encodeIfPresent(teamUuid, forKey: .teamUuid)
      }
    }

    public struct RefusedMembersElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case login = "login"
        case refuseReason = "refuseReason"
      }

      public let login: String
      public let refuseReason: String

      public init(login: String, refuseReason: String) {
        self.login = login
        self.refuseReason = refuseReason
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(login, forKey: .login)
        try container.encode(refuseReason, forKey: .refuseReason)
      }
    }

    public let team: Team
    public let proposedMembers: [String]
    public let refusedMembers: [RefusedMembersElement]
    public let accountCreationRequiredMembers: [String]

    public init(
      team: Team, proposedMembers: [String], refusedMembers: [RefusedMembersElement],
      accountCreationRequiredMembers: [String]
    ) {
      self.team = team
      self.proposedMembers = proposedMembers
      self.refusedMembers = refusedMembers
      self.accountCreationRequiredMembers = accountCreationRequiredMembers
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(team, forKey: .team)
      try container.encode(proposedMembers, forKey: .proposedMembers)
      try container.encode(refusedMembers, forKey: .refusedMembers)
      try container.encode(accountCreationRequiredMembers, forKey: .accountCreationRequiredMembers)
    }
  }
}
