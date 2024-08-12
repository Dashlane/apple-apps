import Foundation
import MacrosKit
import SwiftUI

@ViewInit
struct MyView<Content: View>: View {
  @StateObject
  var model: MyModel

  @ObservedObject
  var model2: MyModel

  @State
  var state: String = ""

  @Binding
  var binding: String

  let fixedParam: String = ""
  let param: Bool
  var param2: Bool

  @ViewBuilder
  var content: () -> Content

  var body: some View {
    Text("View")
  }
}

extension EnvironmentValues {

  @EnvironmentValue
  var totoFoo: String?

  @EnvironmentValue
  var foo2: String = "foo"
}
