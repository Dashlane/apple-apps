import SwiftUI
import CoreLocalization

struct ModalAlertView: View {

    let title: String
    let message: String
    let actionTitle: String
    let cancel: () -> Void
    let action: () -> Void

    @Binding
    var isVisible: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(Typography.smallHeader)
                        .multilineTextAlignment(.leading)
                    Text(message)
                        .font(Typography.caption2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            HStack {
                Spacer()
                Button(CoreLocalization.L10n.Core.cancel,
                       action: {
                    isVisible = false
                    cancel()
                })
                .buttonStyle(DashlaneDefaultButtonStyle(backgroundColor: .clear,
                                                        borderColor: Color(asset: Asset.selection),
                                                        foregroundColor: Color(asset: Asset.primaryHighlight)))

                Button(actionTitle, action: {
                    isVisible = false
                    action()
                } )
                    .buttonStyle(DashlaneDefaultButtonStyle())
            }
            .frame(height: 32)
        }
        .padding()
        .background(Color(asset: Asset.mainBackground))
        .cornerRadius(4)
    }
}

struct ModalAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ModalAlertView(title: "Title",
                       message: "Message",
                       actionTitle: "Action", cancel: {},
                       action: {},
                       isVisible: Binding<Bool>.constant(true))
    }
}
