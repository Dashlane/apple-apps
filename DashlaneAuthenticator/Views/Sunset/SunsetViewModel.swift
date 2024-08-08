import AuthenticatorKit
import Combine
import Foundation
import PDFKit
import SwiftUI

@MainActor
final class SunsetViewModel: ObservableObject {

  @Published
  var tokens = [OTPInfo]()

  @Published
  var pdfDocument: PDFDocument?

  private let databaseService: AuthenticatorDatabaseServiceProtocol

  init(databaseService: AuthenticatorDatabaseServiceProtocol) {
    self.databaseService = databaseService

    databaseService.codesPublisher
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .map({ $0.sortedByIssuer() })
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .assign(to: &$tokens)
  }

  func makePDF() {
    guard pdfDocument == nil, !tokens.isEmpty else {
      return
    }
    pdfDocument = try? PDFDocument(url: tokens.makePDF())
  }
}
