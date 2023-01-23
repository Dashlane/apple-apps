import SwiftUI
import DashlaneAppKit
import SwiftTreats

struct PopSheet {
    struct Button: Identifiable {
        enum Kind {
            case `default`
            case cancel
            case destructive
        }

        let kind: Kind
        let label: Text
        let action: (() -> Void)?
        let id = UUID()

                public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Button {
            Button(kind: .default, label: label, action: action)
        }

                public static func cancel(_ label: Text, action: (() -> Void)? = {}) -> Button {
            Button(kind: .cancel, label: label, action: action)
        }

                public static func cancel(_ action: (() -> Void)? = {}) -> Button {
            Button(kind: .cancel, label: Text(L10n.Localizable.cancel), action: action)
        }

                public static func destructive(_ label: Text, action: (() -> Void)? = {}) -> Button {
            Button(kind: .destructive, label: label, action: action)
        }
    }

    let title: Text
    let message: Text?
    let buttons: [PopSheet.Button]

    init(title: Text, message: Text? = nil, buttons: [PopSheet.Button] = [.cancel()]) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }

    func actionSheet() -> ActionSheet {
        var buttons = self.buttons
        if !buttons.contains(where: { $0.kind == .cancel}) { 
            buttons.append(.cancel())
        }

        return ActionSheet(title: title, message: message, buttons: buttons.map({ popButton in
            switch popButton.kind {
                case .default: return .default(popButton.label, action: popButton.action)
                case .cancel: return .cancel(popButton.label, action: popButton.action)
                case .destructive: return .destructive(popButton.label, action: popButton.action)
            }
        }))
    }

    func popover(isPresented: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            self.title
                .font(.subheadline)
                .foregroundColor(Color(asset: FiberAsset.placeholder))
                .padding()
            ForEach(self.buttons.filter({ $0.kind != .cancel })) { button in
                Divider()
                SwiftUI.Button(action: {
                    isPresented.wrappedValue = false
                    DispatchQueue.main.async {
                        button.action?()
                    }
                }, label: {

                    if button.kind == .destructive {
                        button.label
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    } else {
                        button.label
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }

                })
                    .accentColor(Color(asset: FiberAsset.accentColor))
                    .padding()
            }
        }.frame(minWidth: 300)
    }

}

extension View {
    func popSheet(isPresented: Binding<Bool>, attachmentAnchor: PopoverAttachmentAnchor = .point(.topTrailing), arrowEdge: Edge = .bottom, content: @escaping () -> PopSheet) -> some View {
        Group {
            if Device.isIpadOrMac {
                popover(isPresented: isPresented,
                        attachmentAnchor: attachmentAnchor,
                        arrowEdge: arrowEdge,
                        content: { content().popover(isPresented: isPresented) })
            } else {
                actionSheet(isPresented: isPresented, content: { content().actionSheet() })
            }
        }
    }
}
