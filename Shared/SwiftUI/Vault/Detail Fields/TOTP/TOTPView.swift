import Foundation
import SwiftUI
import TOTPGenerator

struct TOTPView: View {
        
    @Binding
    var code: String
    
    let token: OTPConfiguration
    
    let period: TimeInterval

    @State
    var progress: CGFloat = 0.0
    
    @State
    var remainingTime: Int = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TimeProgressIndicator(progress: progress, code: code)
            .onAppear() {
                update()
            }
            .onReceive(timer) { _ in
                update()
            }
    }
    
    func update() {
        let remainingTime = TOTPGenerator.timeRemaining(in: period)
        self.remainingTime = Int(remainingTime)
        self.progress = CGFloat((period - remainingTime) / period)
        self.code = TOTPGenerator.generate(with: token.type, for: Date(), digits: token.digits, algorithm: token.algorithm, secret: token.secret)
    }
}

struct TOTPRowView_preview: PreviewProvider {
    static var previews: some View {
        TOTPView(code: .constant(""), token: OTPConfiguration.mock, period: 30)
    }
}

