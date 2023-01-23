import Foundation
import SecurityDashboard
import DesignSystem
import SwiftUI

private protocol PopupAlertShowable {
    func generateMessage() -> NSAttributedString
}

struct PopupAlert {

    let alert: PopupAlertProtocol
    let title: String
    let message: NSAttributedString

    init(_ popupAlert: PopupAlertProtocol) {

        self.alert = popupAlert
        self.title = popupAlert.title

        guard let showableAlert = popupAlert as? PopupAlertShowable else {
            fatalError()
        }

        let content = NSMutableAttributedString(string: "\n")
        content.append(showableAlert.generateMessage())
        self.message = content
    }
}

extension DashlaneSixPopupAlert: PopupAlertShowable {
    func generateMessage() -> NSAttributedString {
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
            description,
            dataInvolved,
            recommendation
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))
            .overrideAllString(with: defaultTextAttributes)

        return message
    }
}

extension DataLeakHiddenPopupAlert: PopupAlertShowable {
    func generateMessage() -> NSAttributedString {
        let date: NSAttributedString? = {
            guard let alertDate = self.date else { return nil }
            return alertDate.attributedString(withContentAttributes: redTextAttributes)
        }()

        let dataInvolved: NSAttributedString? = {
            guard let details = self.details else { return nil }
            return details.attributedString(withContentJoinedBy: ", ", attributes: redTextAttributes)
        }()

        let explanations: NSAttributedString? = {
            guard let alertExplanations = self.explanations else { return nil }
            let title = NSMutableAttributedString(string: alertExplanations.title.data, attributes: boldTextAttributes)
            let message = NSAttributedString(string: "\n\(alertExplanations.contents.first!)")
            title.append(message)
            return title
        }()

        let message = NSMutableAttributedString(attributedString: [
            date,
            dataInvolved,
            explanations
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))
            .overrideAllString(with: defaultTextAttributes)

        return message
    }
}

extension DataLeakContentPopupAlert: PopupAlertShowable {
    func generateMessage() -> NSAttributedString {
        let dataInvolved: NSAttributedString? = {
            guard let details = self.details else { return nil }
            return details.attributedString(withContentAttributes: redTextAttributes, splittedBy: "_")
        }()

        let message = NSMutableAttributedString(attributedString: [
            dataInvolved
            ]
            .compactMap { $0 }
            .joined(by: "\n\n"))
            .overrideAllString(with: defaultTextAttributes)

        return message
    }
}

extension DataLeakUpsellPremiumPlusPopupAlert: PopupAlertShowable {
    func generateMessage() -> NSAttributedString {
        let dataInvolved: NSAttributedString? = {
            guard let details = self.details else { return nil }
            return details.attributedString(withContentAttributes: redTextAttributes, splittedBy: "_")
        }()

        let explanations: NSAttributedString? = {
            guard let description = self.explanations else { return nil }
            return description.attributedString(withContentAttributes: [:])
        }()

        let message = [
            dataInvolved,
            explanations
            ]
            .compactMap { $0 }
            .joined(by: "\n\n")
            .overrideAllString(with: defaultTextAttributes)

        return message
    }
}

extension DataLeakPlaintextPopupAlert: PopupAlertShowable {

    func generateMessage() -> NSAttributedString {

        let alertDate = date?.attributedString(withContentAttributes: boldTextAttributes)
        let affectedPasswords = details?.attributedString(withContentAttributes: redTextAttributes)

        let otherCredentialsImpacted = self.recommendation?.attributedString(withContentAttributes: redTextAttributes)

        let message = [
            alertDate,
            affectedPasswords,
            otherCredentialsImpacted
            ]
            .compactMap { $0 }
            .joined(by: "\n\n")
            .overrideAllString(with: defaultTextAttributes)

        return message
    }

}

private var messageFontSize: CGFloat = 13.0

private var defaultTextAttributes: [NSAttributedString.Key: NSObject] {
    let font = UIFont.systemFont(ofSize: messageFontSize, weight: .regular)
    let fontMetrics = UIFontMetrics(forTextStyle: .body)
    return [NSAttributedString.Key.font: fontMetrics.scaledFont(for: font)]
}

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

private var boldTextAttributes: [NSAttributedString.Key: NSObject] {
    let font = UIFont.systemFont(ofSize: messageFontSize, weight: .bold)
    let fontMetrics = UIFontMetrics(forTextStyle: .body)
    return [NSAttributedString.Key.foregroundColor: UIColor.ds.text.neutral.standard,
            NSAttributedString.Key.font: fontMetrics.scaledFont(for: font)]
}

private extension Array where Element == NSAttributedString {
    func joined(by separator: String) -> NSMutableAttributedString {
        return self.reduce(NSMutableAttributedString()) { (result, attributedStringToAppend) -> NSMutableAttributedString in
            if result.string.count > 0 {
                result.append(NSAttributedString(string: separator))
            }
            result.append(attributedStringToAppend)
            return result
        }
    }
}

private extension NSMutableAttributedString {

    func overrideAllString(with attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let newAttributedString = NSMutableAttributedString(string: self.string, attributes: attributes)

        self.enumerateAttributes(in: NSRange.init(location: 0, length: self.string.count), options: .longestEffectiveRangeNotRequired) { (attributes, range, _) in
            newAttributedString.addAttributes(attributes, range: range)
        }
        return newAttributedString
    }
}
