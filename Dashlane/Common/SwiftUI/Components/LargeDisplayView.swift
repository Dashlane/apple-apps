import SwiftUI
import UIComponents

struct LargeDisplayView: View {

    @Binding
    var text: String
    var body: some View {
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
        let coloredText = (Array(text)).map { (char) -> Text in
            Text(String(char))
                .font(Font.system(.title, design: .monospaced))
                .foregroundColor(Color(passwordChar: char))

        }.joined()

        return coloredText
            .padding()
            .modifier(AlertStyle())
    }

}

struct LargeDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        LargeDisplayView(text: .constant("12gfhgfgj{]0o00"))
    }
}

extension Array where Element == Text {
    func joined() -> Text {
        var text: Text = Text("")
        self.forEach {
            text =  text + $0
        }
        return text
    }
}
