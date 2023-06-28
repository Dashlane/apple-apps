import Foundation
import SwiftUI
import TOTPGenerator

public struct TOTPView: View {
    @Binding var code: String
    @State var progress: CGFloat = 0.0
    @State var remainingTime: Int = 0

    let period: TimeInterval
    let token: OTPConfiguration
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(
        code: Binding<String>,
        token: OTPConfiguration,
        period: TimeInterval
    ) {
        self._code = code
        self.token = token
        self.period = period
        self.progress = progress
        self.remainingTime = remainingTime
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: 1 - progress)
            .stroke(loaderColor, lineWidth: 2)
            .rotationEffect(.degrees(-90))
            .background(Circle().stroke(loaderBackgroundColor, lineWidth: 2))
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
            .frame(width: 20, height: 20)
            .animation(.linear(duration: 1), value: progress)
            .transition(.identity)
            .id(code)
            .onAppear {
                update()
            }
            .onReceive(timer) { _ in
                update()
            }
    }
    
    var loaderColor: Color {
        Color(
            red: 149 / 255,
            green: 185 / 255,
            blue: 192 / 255
        )
    }
    
    var loaderBackgroundColor: Color {
        Color(
            red: 32 / 255,
            green: 33 / 255,
            blue: 33 / 255
        )
    }

    func update() {
        let remainingTime = TOTPGenerator.timeRemaining(in: period)
        self.remainingTime = Int(remainingTime)
        self.progress = CGFloat((period - remainingTime) / period)
        self.code = TOTPGenerator.generate(
            with: token.type,
            for: Date(),
            digits: token.digits,
            algorithm: token.algorithm,
            secret: token.secret
        ).groupedBy3
    }
}


struct TOTPRowView_preview: PreviewProvider {
    static var previews: some View {
        TOTPView(
            code: .constant(""),
            token: OTPConfiguration.mock,
            period: 30
        )
    }
}

fileprivate extension String {
    var groupedBy3: String {
        assert(self.count == 6)
        let first = self[startIndex ..< index(startIndex, offsetBy: 3)]
        let last = self[index(startIndex, offsetBy: 3) ..< endIndex]
        return "\(first) \(last)"
    }
}
