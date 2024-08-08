import CoreLocalization
import CoreNetworking
import DashTypes
import Foundation
import UIKit

struct SecurityTokenAlertBuilder {

  struct FetchTokenError: Error {}

  let log: Logger

  func buildAlertController(with token: String?, completion: @escaping (UIViewController?) -> Void)
  {
    if let token = token, !token.isEmpty {
      completion(alertController(for: token))
      return
    }
    completion(nil)
  }

  func parse(data: Data) throws -> String {

    guard let token = String(data: data, encoding: .utf8) else {
      throw FetchTokenError()
    }
    return token
  }

  private func alertController(for token: String) -> UIViewController {
    let title = CoreLocalization.L10n.Core.kwTokenPlaceholderText

    let fontSize: CGFloat = 42.0

    let attributedMessage = NSMutableAttributedString(string: "\n\n")

    let attributedToken = NSMutableAttributedString(
      string: token,
      attributes: [
        .font: UIFont.systemFont(ofSize: fontSize),
        .kern: 4.0,
      ])
    attributedToken.addAttributes(
      [.kern: 15.0],
      range: NSRange(location: token.count / 2 - 1, length: 1))

    attributedMessage.insert(attributedToken, at: 1)

    let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)

    alert.setValue(attributedMessage, forKey: "attributedMessage")
    alert.addAction(
      UIAlertAction(title: CoreLocalization.L10n.Core.kwButtonOk, style: .default, handler: nil))

    return alert
  }
}
