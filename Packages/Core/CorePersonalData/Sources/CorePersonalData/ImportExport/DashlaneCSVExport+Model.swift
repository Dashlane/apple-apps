import Foundation

#if canImport(SwiftUI)

  extension DashlaneCSVExport {
    public struct CredentialExport: Codable {
      let username: String
      let username2: String?
      let username3: String?
      let title: String
      let password: String
      let note: String?
      let url: String?
      let category: String?
      let otp: String?

      init(credential: Credential) {
        username = credential.email
        username2 = credential.login
        username3 = credential.secondaryLogin
        title = credential.displayTitle
        password = credential.password
        note = credential.note
        url = credential.url?.rawValue
        category = nil
        otp = credential.otpURL?.absoluteString
      }
    }
  }

  extension DashlaneCSVExport {
    struct SecureNoteExport: Codable {
      let title: String
      let note: String
      let category: String?

      init(secureNote: SecureNote) {
        title = secureNote.title
        note = secureNote.content
        category = nil
      }
    }
  }

  extension DashlaneCSVExport {
    struct PaymentExport: Codable {
      enum PaymentType: String, Codable {
        case paymentCard = "payment_card"
        case bank = "bank"
      }

      let type: PaymentType
      var accountName: String?
      var accountHolder: String?
      var ccNumber: String?
      var code: String?
      var expirationMonth: Int?
      var expirationYear: Int?
      var routingNumber: String?
      var accountNumber: String?
      let country: String?
      let issuingBank: String?
      var note: String?
      var name: String?

      init(creditCard: CreditCard) {
        type = .paymentCard

        accountName = creditCard.ownerName

        ccNumber = creditCard.cardNumber
        code = creditCard.securityCode
        expirationMonth = creditCard.expireMonth
        expirationYear = creditCard.expireYear
        country = creditCard.country?.code
        issuingBank = creditCard.bank?.code
        note = creditCard.note
        name = creditCard.name
      }

      init(bankAccount: BankAccount) {
        type = .bank
        accountName = bankAccount.name
        accountHolder = bankAccount.owner

        routingNumber = bankAccount.bic
        accountNumber = bankAccount.iban
        country = bankAccount.country?.code
        issuingBank = bankAccount.bank?.code
      }
    }
  }

  extension DashlaneCSVExport {
    struct IdExport: Codable {
      enum IdType: String, Codable {
        case card
        case passport
        case license
        case socialSecurity = "social_security"
        case taxNumber = "tax_number"

      }

      let type: IdType
      let number: String?
      var name: String?
      @CalendarDateFormatted var issueDate: Date?
      @CalendarDateFormatted var expirationDate: Date?
      var placeOfIssue: String?
      var state: String?

      init(idCard: IDCard) {
        type = .card
        number = idCard.number
        name = idCard.displayFullName
        _issueDate = .init(idCard.deliveryDate)
        _expirationDate = .init(idCard.expireDate)
      }

      init(passport: Passport) {
        type = .passport
        number = passport.number
        name = passport.displayFullName
        _issueDate = .init(passport.deliveryDate)
        _expirationDate = .init(passport.expireDate)
        placeOfIssue = passport.deliveryPlace
      }

      init(license: DrivingLicence) {
        type = .license
        number = license.number
        name = license.displayFullName
        _issueDate = .init(license.deliveryDate)
        _expirationDate = .init(license.expireDate)
      }

      init(socialSecurityInformation: SocialSecurityInformation) {
        type = .socialSecurity
        number = socialSecurityInformation.number
        name = socialSecurityInformation.displayFullName
      }

      init(fiscalInformation: FiscalInformation) {
        type = .taxNumber
        number = fiscalInformation.fiscalNumber
      }
    }
  }

  extension DashlaneCSVExport {
    struct PersonalInfoExport: Codable {
      enum ContactType: String, Codable {
        case name
        case email
        case number
        case address
        case company
        case website
      }

      let type: ContactType

      var title: String?
      var firstName: String?
      var middleName: String?
      var lastName: String?
      var login: String?
      @CalendarDateFormatted var dateOfBirth: Date?
      var placeOfBirth: String?

      var email: String?
      var emailType: String?

      var itemName: String?

      var phoneNumber: String?

      var address: String?
      var country: String?
      var state: String?
      var city: String?
      var zip: String?
      var addressRecipient: String?
      var addressBuilding: String?
      var addressApartment: String?
      var addressFloor: String?
      var addressDoorCode: String?

      var jobTitle: String?

      var url: String?

      init(identity: Identity) {
        type = .name
        title = identity.personalTitle != .noneOfThese ? identity.personalTitle.rawValue : nil
        firstName = identity.firstName
        middleName = identity.middleName
        lastName = identity.lastName
        login = identity.pseudo
        dateOfBirth = identity.birthDate
        placeOfBirth = identity.birthPlace
      }

      init(email: Email) {
        type = .email
        self.email = email.value
        emailType = email.type == .personal ? "personal" : "business"
        self.itemName = email.name
      }

      init(phone: Phone) {
        type = .number
        self.phoneNumber = phone.displayPhone
        self.itemName = phone.name
      }

      init(address: Address) {
        type = .address
        itemName = address.name
        self.address = address.addressFull
        self.country = address.country?.code
        self.state = address.state?.code
        self.city = address.city
        self.zip = address.zipCode
        self.addressRecipient = address.receiver
        self.addressBuilding = address.building
        self.addressApartment = address.door
        self.addressFloor = address.floor
        self.addressDoorCode = address.digitCode
      }

      init(company: Company) {
        type = .company
        jobTitle = company.jobTitle
        itemName = company.name
      }

      init(website: PersonalWebsite) {
        type = .website
        itemName = website.name
        url = website.website
      }
    }

  }

  extension DashlaneCSVExport {
    struct WifiExport: Codable {
      let ssid: String
      let passphrase: String
      let name: String
      let note: String
      let hidden: Bool
      let encriptionType: String

      init(wifi: WiFi) {
        ssid = wifi.ssid
        passphrase = wifi.passphrase
        name = wifi.name
        note = wifi.note
        hidden = wifi.hidden
        encriptionType = wifi.encryptionType.rawValue
      }
    }
  }

#endif
