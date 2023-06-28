#if canImport(UIKit)

import Foundation
import SwiftUI
import UIKit

public extension NavigationView {
                func navigationBarDefaultStyle(_ style: NavigationBarStyle) -> some View {
        return self.onAppear {
            let bar = UINavigationBar.appearance()
            let previousStyle = bar.currentStyle
            bar.apply(style)

            DispatchQueue.main.async {
                guard bar.currentStyle == style else {
                    return
                }

                bar.apply(previousStyle)
            }
        }
    }
}

struct NavigationViewDefaultBarStyle_Previews: PreviewProvider {
    struct SecondScreen: View {
        @Environment(\.dismiss)
        private var dismiss

        var body: some View {
            Button("Dismiss", action: dismiss.callAsFunction)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Second")
        }
    }

    static var previews: some View {
        NavigationView {
            NavigationLink("Push", destination: SecondScreen())
                .navigationTitle("Home")
        }.navigationBarDefaultStyle(.yellowWhyNot)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
#endif
