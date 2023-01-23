import Foundation
import SwiftUI
import VaultKit

protocol CopiableDetailField: View {
    var copiableValue: Binding<String> { get }
    var title: String { get }
    var fiberFieldType: DetailFieldType { get }
}

extension TextDetailField: CopiableDetailField {
    var copiableValue: Binding<String> {
        $text
    }
}

extension TOTPDetailField: CopiableDetailField {
    var copiableValue: Binding<String> {
        $code
    }
}

extension SecureDetailField: CopiableDetailField {
    var copiableValue: Binding<String> {
        $text
    }
}

extension NotesDetailField: CopiableDetailField {
    var copiableValue: Binding<String> {
        $text
    }
}

extension BreachTextField: CopiableDetailField {
    var copiableValue: Binding<String> {
        $text
    }
}

extension BreachPasswordField: CopiableDetailField {
    var copiableValue: Binding<String> {
        $text
    }
}

extension BreachPasswordGeneratorField: CopiableDetailField {
    var copiableValue: Binding<String> {
        .constant(text)
    }
}

extension SecureDetailField {
    @ViewBuilder
    func copyAction(canCopy: Bool, copyAction: @escaping (String) -> Void) -> some View {
        if !canCopy {
            self
        } else {
            self.modifier(ActionableFieldModifier(title: L10n.Localizable.kwCopyButton,
                                                  isHidden: copiableValue.wrappedValue.isEmpty,
                                                  action: {
                                                    copyAction(self.copiableValue.wrappedValue)
                                                  }))
        }
    }
}
