import SwiftUI
import VaultKit

struct DetailFieldActionSheet: ViewModifier {

    enum Action {
        case copy((_ value: String, _ fieldType: DetailFieldType) -> Void)
        case largeDisplay
    }

    let title: String
    @Binding
    var text: String
    let actions: [DetailFieldActionSheet.Action]
    let hasAccessory: Bool
    let requestAccess: (@escaping (Bool) -> Void) -> Void

    @State
    var showActionSheet: Bool = false

    @State
    var showLargeDisplay: Bool = false

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.sizeCategory)
    var sizeCategory

    @Environment(\.detailFieldType)
    var fieldType

    @ViewBuilder
    func body(content: Content) -> some View {
        HStack(spacing: 4) {
            if detailMode.isEditing {
                content
            } else {

                #if targetEnvironment(macCatalyst) 
                content
                    .contextMenu {
                        if self.actions.copyAction != nil {
                            Button(L10n.Localizable.kwCopy, action: copy)
                        }
                        if self.actions.hasLargeDisplay {
                            Button(L10n.Localizable.editMenuShowLargeCharacters, action: requestLargeDisplay)
                        }
                    }
                #else 
                content
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !self.text.isEmpty && !self.actions.isEmpty {
                            self.showActionSheet = true
                        }
                    }
                    .onLongPressGesture {
                        if !self.text.isEmpty && self.actions.hasLargeDisplay {
                            requestLargeDisplay()
                        }
                    }.actionSheet(isPresented: self.$showActionSheet) {
                        self.detailFieldActionSheet
                    }
                #endif
            }

            if detailMode == .viewing && !self.text.isEmpty && self.actions.copyAction != nil && hasAccessory {
                Spacer()
                Button(action: copy, label: {
                    Text(L10n.Localizable.kwCopy)
                        .font(sizeCategory.isAccessibilityCategory ? .footnote : .body) 
                })
                .accentColor(Color(asset: FiberAsset.accentColor))
            }
        }
        .overFullScreen(isPresented: $showLargeDisplay) {
            LargeDisplayView(text: self.$text)
                .onTapGesture {
                    self.showLargeDisplay = false
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.applicationWillResignActiveNotification)) { _ in
            self.showLargeDisplay = false
        }
    }

    private func copy() {
        self.actions.copyAction?(self.text, self.fieldType)
    }

    private func requestLargeDisplay() {
        self.requestAccess { canAccess in
            self.showLargeDisplay = canAccess
        }
    }
}

extension DetailFieldActionSheet {
    private var detailFieldActionSheet: ActionSheet {
        ActionSheet(title: Text(title), message: nil, buttons: actionButtons)
    }

    private var actionButtons: [ActionSheet.Button] {

        var buttons: [ActionSheet.Button] = actions.map { action in
            switch action {
            case .copy(let action):
                return copyButton(action: action)
            case .largeDisplay:
                return largeDisplayButton
            }
        }
        buttons.append(.cancel())
        return buttons
    }

    private func copyButton(action: @escaping (String, DetailFieldType) -> Void) -> ActionSheet.Button {
        .default(Text(L10n.Localizable.kwCopy), action: {
            action(self.text, self.fieldType)
        })
    }

    private var largeDisplayButton: ActionSheet.Button {
        .default(Text(L10n.Localizable.editMenuShowLargeCharacters), action: requestLargeDisplay)
    }
}

extension CopiableDetailField {
    func actions(_ actions: [DetailFieldActionSheet.Action],
                 hasAccessory: Bool = true,
                 accessHandler: ((@escaping (Bool) -> Void) -> Void)? = nil) -> some View {
        self.modifier(DetailFieldActionSheet(title: title,
                                             text: copiableValue,
                                             actions: actions,
                                             hasAccessory: hasAccessory, requestAccess: { completion in
            if accessHandler == nil {
                completion(true)
            } else {
                accessHandler?(completion)
            }
        }))
    }

}

extension Array where Element == DetailFieldActionSheet.Action {
    var copyAction: ((String, DetailFieldType) -> Void)? {
        var result: ((String, DetailFieldType) -> Void)?
        self.forEach {
            switch $0 {
            case .copy(let action):
                result = action
            default: break
            }
        }
        return result
    }

    var hasLargeDisplay: Bool {
        var result = false
        self.forEach {
            switch $0 {
            case .largeDisplay:
                result = true
            default: break
            }
        }
        return result
    }
}
