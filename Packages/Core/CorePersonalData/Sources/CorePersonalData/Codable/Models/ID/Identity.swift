import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData
public struct Identity: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .id

  public enum Mode {
    case european
    case northAmerican
    case spanish
    case japanese
  }

  public enum PersonalTitle: String, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: PersonalTitle = .noneOfThese

    public var id: String {
      return self.rawValue
    }

    case mr = "MR"
    case mrs = "MME"
    case miss = "MLLE"
    case ms = "MS"
    case mx = "MX"
    case noneOfThese = "NONE_OF_THESE"
  }

  @Defaulted
  @CodingKey("title")
  public var personalTitle: PersonalTitle
  @Searchable
  public var firstName: String
  @Searchable
  public var middleName: String
  @Searchable
  public var lastName: String
  @Searchable
  public var lastName2: String
  @Searchable
  public var pseudo: String
  @CalendarDateFormatted
  public var birthDate: Date?
  public var birthPlace: String
  @CodingKey("localeFormat")
  public var nationality: CountryCodeNamePair?
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?
  public var spaceId: String?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  public var mode: Mode {
    guard let nationality = self.nationality ?? CountryCodeNamePair.systemCountryCode else {
      return .northAmerican
    }
    return nationality.identityMode
  }

  @Searchable
  public var displayName: String {
    return [firstName, middleName, lastName].joinedName()
  }

  @Searchable
  public var displayNameInverted: String {
    return [lastName, middleName, firstName].joinedName()
  }

  @Searchable
  public var displayNameWithoutMiddleName: String {
    return [firstName, lastName].joinedName()
  }

  @Searchable
  public var displayNameWithoutMiddleNameInverted: String {
    return [lastName, firstName].joinedName()
  }

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    _personalTitle = .init(.mr)
    firstName = ""
    middleName = ""
    lastName = ""
    lastName2 = ""
    pseudo = ""
    birthPlace = ""
    nationality = CountryCodeNamePair.systemCountryCode
    creationDatetime = Date()
    _attachments = .init(nil)
  }

  init(
    id: Identifier,
    personalTitle: Identity.PersonalTitle,
    firstName: String,
    middleName: String,
    lastName: String,
    lastName2: String,
    pseudo: String,
    birthDate: String?,
    birthPlace: String,
    nationality: CountryCodeNamePair? = nil,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    _personalTitle = .init(personalTitle)
    self._birthDate = CalendarDateFormatted(rawValue: birthDate)
    self.firstName = firstName
    self.middleName = middleName
    self.lastName = lastName
    self.lastName2 = lastName2
    self.pseudo = pseudo
    self.birthPlace = birthPlace
    self.nationality = nationality
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.spaceId = spaceId
    _attachments = .init(nil)
  }
}

extension Identity {
  public func validate() throws {
    if firstName.isEmptyOrWhitespaces() && middleName.isEmptyOrWhitespaces()
      && lastName.isEmptyOrWhitespaces()
    {
      throw ItemValidationError(invalidProperty: \Identity.firstName)
    }
  }

  public mutating func prepareForSaving() {
    if pseudo.isEmpty && !defaultLogin.isEmpty {
      pseudo = defaultLogin
    }
  }
}

extension Identity: SearchValueConvertible {
  public var combined: String {
    [
      displayName,
      displayNameInverted,
      displayNameWithoutMiddleName,
      displayNameWithoutMiddleNameInverted,
    ].joined(separator: " ")
  }

  public var searchValue: String? {
    return combined
  }
}

extension Identity: Displayable {
  public var displayTitle: String {
    return displayName
  }

  public var displaySubtitle: String? {
    return defaultLogin
  }

  public var defaultLogin: String {
    if !pseudo.isEmpty {
      return pseudo
    }
    return [firstName, lastName]
      .joinedName(separator: ".")
      .replacingOccurrences(of: " ", with: "")
      .lowercased()
  }

  public var gender: Gender? {
    switch personalTitle {
    case .mr:
      return .male
    case .miss, .mrs, .ms:
      return .female
    case .mx, .noneOfThese:
      return nil

    }
  }
}

extension Array where Element == String {
  fileprivate func joinedName(separator: String = " ") -> String {
    self
      .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: separator)
  }
}

extension CountryCodeNamePair {
  var identityMode: Identity.Mode {
    if ["BE", "CH", "DE", "IT", "NL", "NO", "SE", "AT", "DK", "FR", "LU", "GB", "IE", "BR"]
      .contains(code)
    {
      return .european
    } else if ["MX", "CL", "CO", "ES", "PE", "PT", "AR"].contains(code) {
      return .spanish
    } else if ["JP"].contains(code) {
      return .japanese
    } else {
      return .northAmerican
    }
  }
}

public protocol IdentityLinked {
  var linkedIdentity: Identity? { get }
}

extension IdentityLinked {
  public var linkedIdentityFullName: String? {
    return linkedIdentity?.displayName
  }
}
