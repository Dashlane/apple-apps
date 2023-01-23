import Foundation
import SecurityDashboard
import DesignSystem
import SwiftUI

private protocol UnresolvedAlertShowable {
    func generateMessage() -> NSAttributedString
    func generateActionableMessage() -> UnresolvedAlertActionableMessage?
    func generatePostActionableMessage() -> NSAttributedString?
}

extension UnresolvedAlertShowable {
    func generateActionableMessage() -> UnresolvedAlertActionableMessage? { return nil }
    func generatePostActionableMessage() -> NSAttributedString? { return nil }
}

public protocol UnresolvedAlertActionableMessage {
    var state: DataLeakPlaintextTrayAlert.Actionable.State { get }
    var message: NSAttributedString { get }
    var icon: UIImage { get }
    func action()
}

public struct UnresolvedAlert {

    let alert: TrayAlertProtocol
    let title: NSAttributedString?
    let message: NSAttributedString
    let actionableMessage: UnresolvedAlertActionableMessage?
    let postActionableMessage: NSAttributedString?

    init(_ trayAlert: TrayAlertProtocol) {

        self.alert = trayAlert
        self.title = UnresolvedAlert.generateTitle(from: trayAlert)

        guard let showableAlert = trayAlert as? UnresolvedAlertShowable else {
            fatalError("Unhandled alert")
        }

        self.message = showableAlert.generateMessage()
        self.actionableMessage = showableAlert.generateActionableMessage()
        self.postActionableMessage = showableAlert.generatePostActionableMessage()
    }

    private static func generateTitle(from alert: TrayAlertProtocol) -> NSAttributedString? {

        var titleString = ""

        if let timestamp = alert.timestamp {
            titleString.append(NSLocalizedString(timestamp, comment: ""))
        }

        titleString += "\n\(alert.title)"

        let attributedString = NSMutableAttributedString(string: titleString)

        guard let rangeOfBreachName = attributedString.string.range(of: alert.title) else {
            return nil
        }

        attributedString.addAttributes(semiboldTextAttributes, range: NSRange(rangeOfBreachName, in: attributedString.string))

        return attributedString
    }
}

extension DashlaneSixTrayAlert: UnresolvedAlertShowable {

    func generateMessage() -> NSAttributedString {

        let alertDate: NSAttributedString? = {
            guard let date = self.date else { return nil }
            return date.attributedString(withContentAttributes: redTextAttributes)
        }()

        let description: NSAttributedString? = {
            guard let description = self.description else { return nil }
            return description.attributedString(withContentAttributes: redTextAttributes)
        }()

        let dataInvolved: NSAttributedString? = {
            guard let details = self.details else { return nil }
            return details.attributedString(withContentJoinedBy: ", ", attributes: redTextAttributes)
        }()

        let recommendation: NSAttributedString? = {
            guard let alertRecommendation = self.recommendation else { return nil }
            return alertRecommendation.attributedString(withContentAttributes: semiboldTextAttributes)
        }()

        let message = NSMutableAttributedString(attributedString: [
            alertDate,
            description,
            dataInvolved,
            recommendation
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))

        return message
    }
}

extension HiddenTrayAlert: UnresolvedAlertShowable {

    func generateMessage() -> NSAttributedString {

        let alertDate: NSAttributedString? = {
            guard let date = self.date else { return nil }
            return date.attributedString(withContentAttributes: redTextAttributes)
        }()

        let dataInvolved: NSAttributedString? = {
            guard let details = self.details else { return nil }
            return details.attributedString(withContentJoinedBy: ", ", attributes: redTextAttributes)
        }()

        let recommendation: NSAttributedString? = {
            guard let alertRecommendation = self.recommendation else { return nil }
            return NSAttributedString(string: alertRecommendation.string())
        }()

        let message = NSMutableAttributedString(attributedString: [
            alertDate,
            dataInvolved,
            recommendation
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))

        return message
    }
}

extension DataLeakContentTrayAlert: UnresolvedAlertShowable {

    func generateMessage() -> NSAttributedString {

        let alertDate: NSAttributedString? = {
            guard let date = self.date else { return nil }
            return date.attributedString(withContentAttributes: redTextAttributes)
        }()

        let dataInvolved: NSAttributedString? = {
            guard let details = self.details else { return nil }
            return details.attributedString(withContentAttributes: redTextAttributes, splittedBy: "_")
        }()

        let message = NSMutableAttributedString(attributedString: [
            alertDate,
            dataInvolved
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))

        return message
    }
}

extension DataLeakPlaintextTrayAlert: UnresolvedAlertShowable {

    public class Actionable: UnresolvedAlertActionableMessage {

        public enum State {
            case visible
            case hidden
        }

        private let clearMessage: NSAttributedString
        private let passwords: [String]

        public private(set) var message: NSAttributedString
        public private(set) var state: State = .hidden

        public var icon: UIImage {
            if state == .hidden {
                return FiberAsset.revealButton.image
            }
            return FiberAsset.revealButtonSelected.image
        }

        init(message: NSAttributedString, passwords: [String]) {
            self.clearMessage = message
            self.message = message
            self.passwords = passwords
            updateMessage(for: self.state)
        }

        public func action() {
            self.state = self.state == .hidden ? .visible : .hidden
            updateMessage(for: self.state)
        }

        private func updateMessage(for state: State) {
            if state == .visible {
                self.message = self.clearMessage
            } else {
                                let passwordsString = self.passwords.joined(separator: ", ")
                let passwordsRange = (self.clearMessage.string as NSString).range(of: passwordsString)
                guard passwordsRange.location != NSNotFound else { return }
                let attributesUsed = self.clearMessage.attributes(at: passwordsRange.location, effectiveRange: nil)
                let hiddenPasswordBullets = "••••••••••••••••••"
                let newMessage = self.clearMessage.string.replacingOccurrences(of: passwordsString, with: hiddenPasswordBullets)
                let rangeOfBullets = (newMessage as NSString).range(of: hiddenPasswordBullets)
                let newMessageAttributed = NSMutableAttributedString(string: newMessage)
                newMessageAttributed.addAttributes(attributesUsed, range: rangeOfBullets)
                self.message = newMessageAttributed
            }
        }
    }

    func generateMessage() -> NSAttributedString {

        let alertDate = date?.attributedString(withContentAttributes: redTextAttributes)
        let affectedEmails = details?.attributedString(withContentAttributes: redTextAttributes)

        let message = NSMutableAttributedString(attributedString: [
            alertDate,
            affectedEmails
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))

        return message
    }

    func generateActionableMessage() -> UnresolvedAlertActionableMessage? {

        let leakedPasswords = self.leakedPasswords?.attributedString(withContentAttributes: redTextAttributes)

        guard let leakedPasswordsMessage = leakedPasswords else { return nil }
        guard let passwords = self.leakedPasswords?.contents else { return nil }

        return Actionable(message: leakedPasswordsMessage, passwords: passwords)
    }

    func generatePostActionableMessage() -> NSAttributedString? {
        return self.recommendation?.attributedString(withContentAttributes: redTextAttributes)
    }
}

private extension Array where Element == NSAttributedString {
    func joined(by separator: String) -> NSAttributedString {
        return self.reduce(NSMutableAttributedString()) { (result, attributedStringToAppend) -> NSMutableAttributedString in
            if result.string.count > 0 {
                result.append(NSAttributedString(string: separator))
            }
            result.append(attributedStringToAppend)
            return result
        }
    }
}

private var messageFontSize: CGFloat = 17.0

private var redTextAttributes: [NSAttributedString.Key: NSObject] {
    let font = UIFont.systemFont(ofSize: messageFontSize, weight: .medium)
    let fontMetrics = UIFontMetrics(forTextStyle: .body)
    return [NSAttributedString.Key.foregroundColor: UIColor(Color.ds.text.danger.quiet),
            NSAttributedString.Key.font: fontMetrics.scaledFont(for: font)]
}

private var semiboldTextAttributes: [NSAttributedString.Key: NSObject] {
    let font = UIFont.systemFont(ofSize: messageFontSize, weight: .semibold)
    let fontMetrics = UIFontMetrics(forTextStyle: .body)
    return [NSAttributedString.Key.foregroundColor: UIColor(Color.ds.text.neutral.standard),
            NSAttributedString.Key.font: fontMetrics.scaledFont(for: font)]
}

private var messageFontAttribute: [NSAttributedString.Key: NSObject] {
    let font = UIFont.systemFont(ofSize: messageFontSize, weight: .medium)
    let fontMetrics = UIFontMetrics(forTextStyle: .body)
    return [NSAttributedString.Key.font: fontMetrics.scaledFont(for: font)]
}
