import Foundation

public struct KeychainCredential: Equatable {

  public let title: String

  public let url: String

  public let username: String

  public let password: String

  public let notes: String

  public let otpAuth: URL?

  init(
    title: String,
    url: String,
    username: String,
    password: String,
    notes: String,
    otpAuth: String
  ) {
    self.title = title
    self.url = url
    self.username = username
    self.password = password
    self.notes = notes
    self.otpAuth = URL(string: otpAuth)
  }

  init?(csvContent: [String: String]) {
    guard let title = csvContent[KeychainHeader.title.rawValue],
      let url = csvContent[KeychainHeader.url.rawValue],
      let username = csvContent[KeychainHeader.username.rawValue],
      let password = csvContent[KeychainHeader.password.rawValue],
      let notes = csvContent[KeychainHeader.notes.rawValue],
      let otpAuth = csvContent[KeychainHeader.otpAuth.rawValue]
    else { return nil }

    self.init(
      title: title,
      url: url,
      username: username,
      password: password,
      notes: notes,
      otpAuth: otpAuth)
  }

}
