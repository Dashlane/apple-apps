import CodableCSV
import Foundation

#if canImport(SwiftUI)
  import UniformTypeIdentifiers
  import SwiftUI

  public struct DashlaneCSVExport: FileDocument {
    public static var readableContentTypes: [UTType] { [.folder] }

    let credentials: any Collection<Credential>
    let secureNotes: any Collection<SecureNote>
    let creditCards: any Collection<CreditCard>
    let bankAccounts: any Collection<BankAccount>
    let idCards: any Collection<IDCard>
    let passports: any Collection<Passport>
    let drivingLicences: any Collection<DrivingLicence>
    let socialSecurityInformation: any Collection<SocialSecurityInformation>
    let identities: any Collection<Identity>
    let emails: any Collection<Email>
    let phones: any Collection<Phone>
    let addresses: any Collection<Address>
    let companies: any Collection<Company>
    let websites: any Collection<PersonalWebsite>
    let wifi: any Collection<WiFi>

    public init(
      credentials: any Collection<Credential>,
      secureNotes: any Collection<SecureNote>,
      creditCards: any Collection<CreditCard>,
      bankAccounts: any Collection<BankAccount>,
      idCards: any Collection<IDCard>,
      passports: any Collection<Passport>,
      drivingLicences: any Collection<DrivingLicence>,
      socialSecurityInformation: any Collection<SocialSecurityInformation>,
      identities: any Collection<Identity>,
      emails: any Collection<Email>,
      phones: any Collection<Phone>,
      addresses: any Collection<Address>,
      companies: any Collection<Company>,
      websites: any Collection<PersonalWebsite>,
      wifi: any Collection<WiFi>
    ) {

      self.credentials = credentials
      self.secureNotes = secureNotes
      self.creditCards = creditCards
      self.bankAccounts = bankAccounts
      self.idCards = idCards
      self.passports = passports
      self.drivingLicences = drivingLicences
      self.socialSecurityInformation = socialSecurityInformation
      self.identities = identities
      self.emails = emails
      self.phones = phones
      self.addresses = addresses
      self.companies = companies
      self.websites = websites
      self.wifi = wifi
    }

    public init(configuration: ReadConfiguration) throws {
      fatalError("Not implemented")
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      let encoder = CSVEncoder()

      let credentials = credentials.map(CredentialExport.init)

      let secureNotes = secureNotes.map(SecureNoteExport.init)

      let payments = creditCards.map(PaymentExport.init) + bankAccounts.map(PaymentExport.init)

      let ids =
        idCards.map(IdExport.init)
        + passports.map(IdExport.init)
        + drivingLicences.map(IdExport.init)
        + socialSecurityInformation.map(IdExport.init)

      let personalInfo =
        identities.map(PersonalInfoExport.init)
        + emails.map(PersonalInfoExport.init)
        + phones.map(PersonalInfoExport.init)
        + addresses.map(PersonalInfoExport.init)
        + companies.map(PersonalInfoExport.init)
        + websites.map(PersonalInfoExport.init)

      let wifi = wifi.map(WifiExport.init)

      let folderWrapper = FileWrapper(directoryWithFileWrappers: [:])
      folderWrapper.preferredFilename = "Dashlane CSV"

      if !credentials.isEmpty {
        try folderWrapper.addRegularFile(
          withContents: Data(encoder.encode(credentials).utf8),
          preferredFilename: "credentials.csv")
      }

      if !secureNotes.isEmpty {
        try folderWrapper.addRegularFile(
          withContents: Data(encoder.encode(secureNotes).utf8),
          preferredFilename: "secureNotes.csv")
      }

      if !payments.isEmpty {
        try folderWrapper.addRegularFile(
          withContents: Data(encoder.encode(payments).utf8),
          preferredFilename: "payments.csv")
      }

      if !ids.isEmpty {
        try folderWrapper.addRegularFile(
          withContents: Data(encoder.encode(ids).utf8),
          preferredFilename: "ids.csv")
      }
      if !personalInfo.isEmpty {
        try folderWrapper.addRegularFile(
          withContents: Data(encoder.encode(personalInfo).utf8),
          preferredFilename: "personalInfo.csv")
      }

      if !wifi.isEmpty {
        try folderWrapper.addRegularFile(
          withContents: Data(encoder.encode(wifi).utf8),
          preferredFilename: "wifi.csv")
      }

      return folderWrapper
    }
  }
#endif
