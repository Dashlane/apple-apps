import CoreLocalization
import Foundation
import SwiftUI

public protocol CopiableDetailField: View {
  var copiableValue: Binding<String> { get }
  var title: String { get }
  var fiberFieldType: DetailFieldType { get }
}

extension TextDetailField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    $text
  }
}

extension TOTPDetailField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    $code
  }
}

extension SecureDetailField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    $text
  }
}

extension NotesDetailField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    $text
  }
}

extension BreachTextField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    $text
  }
}

extension BreachPasswordField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    $text
  }
}

extension BreachPasswordGeneratorField: CopiableDetailField {
  public var copiableValue: Binding<String> {
    .constant(text)
  }
}
