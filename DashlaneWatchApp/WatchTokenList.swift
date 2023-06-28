import SwiftUI

struct WatchTokenList: View {
    let context: WatchApplicationContext
    
    var body: some View {
        if context.tokens.isEmpty {
            Text(NSLocalizedString("WATCH_WELCOME_NO_TOKENS", tableName: "Watch", comment: ""))
        } else {
            list
        }
    }
    
    var list: some View {
        List {
            ForEach(context.tokens) { token in
                WatchTokenRow(token: token)
            }
        }
    }
}

struct WatchTokenList_Previews: PreviewProvider {
    static var previews: some View {
        WatchTokenList(context: .mock)
    }
}

extension WatchApplicationContext {
    static var mock: WatchApplicationContext {
        .init(tokens: [
            .mockGoogle
        ])
    }
}

extension WatchApplicationContext.Token {
    static var mockGoogle: Self {
        .init(url: .init(string:"otpauth://totp/google%3Atest?secret=7IQI3XLXFILVRFHN7DXNMKLHG7FWZEY3TVUDSPUITUZRSMPRPQQCIKUNTQHU3GAKHSGYCE4YU5U7AGYIT6FSLIDKLAWGVAEB5ESGFWY&issuer=google")!, title: "Google")
    }
}
