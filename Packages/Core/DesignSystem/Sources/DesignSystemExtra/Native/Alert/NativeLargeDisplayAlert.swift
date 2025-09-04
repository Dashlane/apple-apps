import SwiftUI

public struct NativeLargeDisplayAlert: View {
  let text: String

  @ScaledMetric private var width: CGFloat = 16
  @ScaledMetric private var height: CGFloat = 30

  private var columns: [GridItem] {
    [
      GridItem(.adaptive(minimum: width, maximum: width), spacing: -0.5)
    ]
  }

  public init(_ text: String) {
    self.text = text
  }

  public var body: some View {
    textView
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(backgroundView)
  }

  private var backgroundView: some View {
    Color.black.opacity(0.5)
      .edgesIgnoringSafeArea(.all)
      .frame(maxWidth: .infinity)
  }

  var textView: some View {
    NativeAlert {
      passwordText
        .padding()
    }
  }

  private var passwordText: some View {
    LazyVGrid(columns: columns, spacing: 0) {
      ForEach(Array(text.enumerated()), id: \.offset) { character in
        ZStack {
          Text(String(character.element))
            .font(Font.system(.title, design: .monospaced))
            .foregroundStyle(Color(passwordCharacter: character.element))
            .frame(height: height)
            .fixedSize()
        }
        .padding(.vertical, 10)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

struct NativeLargeDisplayAlert_Previews: PreviewProvider {
  static var previews: some View {
    NativeLargeDisplayAlert("12gfhgfgj{]0o00")
  }
}
