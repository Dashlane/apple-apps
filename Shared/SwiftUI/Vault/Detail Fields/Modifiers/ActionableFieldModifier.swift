import SwiftUI
import CorePersonalData
import Combine

struct ActionableFieldModifier: ViewModifier {
    let title: String
    let isHidden: Bool
    let action: () -> Void

    @Environment(\.detailMode)
    var detailMode

    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 4) {
            content
            if detailMode == .viewing && !isHidden {
                Spacer()
                Button(action: action, title: title)
                    .accentColor(Color(asset: FiberAsset.accentColor))
            }
        }
    }
}

extension TextDetailField {
    func openAction(didOpen: (() -> Void)? = nil) -> some View {
        self.modifier(ActionableFieldModifier(title: L10n.Localizable.kwOpen,
                                              isHidden: text.isEmpty,
                                              action: {
                                                if let url =  PersonalDataURL(rawValue: self.text).openableURL {
                                                    didOpen?()
                                                    DispatchQueue.main.async {
                                                        #if !EXTENSION
                                                        UIApplication.shared.open(url)
                                                        #endif
                                                    }
                                                }
        }))
    }
}

extension View {
        func action(_ title: String,
                isHidden: Bool = false,
                action: @escaping () -> Void) -> some View {
        return modifier(ActionableFieldModifier(title: title, isHidden: isHidden, action: action))
    }

}
