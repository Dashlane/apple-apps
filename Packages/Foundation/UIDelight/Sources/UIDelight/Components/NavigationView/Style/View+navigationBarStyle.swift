#if canImport(UIKit)

import Foundation
import UIKit
import SwiftUI

public extension View {
        func navigationBarStyle(_ style: NavigationBarStyle) -> some View {
        self.background(NavigationBarCustomStyle(style: style))
    }
}

private struct NavigationBarCustomStyle: UIViewControllerRepresentable {
    let style: NavigationBarStyle

    func makeUIViewController(context: Context) -> CustomNavigationBarStyleViewController {
        CustomNavigationBarStyleViewController(style: style)
    }

    func updateUIViewController(_ uiViewController: CustomNavigationBarStyleViewController, context: Context) {

    }
}

private final class CustomNavigationBarStyleViewController: UIViewController {
    let style: NavigationBarStyle
    var previousStyle: NavigationBarStyle?
    
    init(style: NavigationBarStyle) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
        self.view = UIView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let bar = self.navigationController?.navigationBar else {
            return
        }
        previousStyle = bar.currentStyle
        bar.apply(style)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

                                guard let bar = self.navigationController?.navigationBar,
              style != bar.currentStyle else {
            return
        }
        previousStyle = bar.currentStyle
        bar.apply(style)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let bar = self.navigationController?.navigationBar,
              let previousStyle = previousStyle ,
              style == bar.currentStyle else {
            return
        }
        bar.apply(previousStyle)
    }
}

struct NavigationViewBarStyle_Previews: PreviewProvider {
    struct SecondScreen: View {
        @Environment(\.dismiss)
        private var dismiss
        
        var body: some View {
            Button("Dismiss", action: dismiss.callAsFunction)
                .navigationTitle("Second")
                .navigationBarStyle(.greenWhyNot)
        }
    }
    
    static var previews: some View {
        NavigationView {
            NavigationLink("Push", destination: SecondScreen())
                .navigationTitle("Home")
                .navigationBarStyle(.purpleWhyNot)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#endif
