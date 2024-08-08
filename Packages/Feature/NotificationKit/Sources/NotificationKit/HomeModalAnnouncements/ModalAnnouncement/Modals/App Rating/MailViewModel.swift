import Foundation

class MailViewModel {
  let subject: String
  let body: String
  let recipients: [String]
  let logFilePath: String?

  init(
    subject: String,
    body: String,
    recipients: [String],
    logFilePath: String? = nil
  ) {
    self.subject = subject
    self.body = body
    self.recipients = recipients
    self.logFilePath = logFilePath
  }
}
