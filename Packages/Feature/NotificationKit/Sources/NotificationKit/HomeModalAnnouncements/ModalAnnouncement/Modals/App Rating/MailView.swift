import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {

  @Environment(\.dismiss)
  private var dismiss

  let model: MailViewModel

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

    var dismiss: DismissAction

    init(dismiss: DismissAction) {
      self.dismiss = dismiss
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(dismiss: dismiss)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>)
    -> MFMailComposeViewController
  {
    let vc = MFMailComposeViewController()
    vc.mailComposeDelegate = context.coordinator
    vc.setSubject(model.subject)
    vc.setMessageBody(model.body, isHTML: false)
    vc.setToRecipients(model.recipients)
    return vc
  }

  func updateUIViewController(
    _ uiViewController: MFMailComposeViewController,
    context: UIViewControllerRepresentableContext<MailView>
  ) {

  }
}
