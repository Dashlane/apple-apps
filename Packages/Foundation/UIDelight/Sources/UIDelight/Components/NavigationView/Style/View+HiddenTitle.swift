#if canImport(UIKit)

import Foundation
import UIKit
import SwiftUI

public extension View {
                    func hiddenNavigationTitle() -> some View {
        self.navigationBarTitleDisplayMode(.inline)
            .background(HiddenNavigationTitleStyle())
    }
}

private struct HiddenNavigationTitleStyle: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> CustomNavigationTitleStyleViewController {
        CustomNavigationTitleStyleViewController()
    }

    func updateUIViewController(_ uiViewController: CustomNavigationTitleStyleViewController, context: Context) {

    }
}

private final class CustomNavigationTitleStyleViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.titleView = UIView()
            topItem.titleView?.isHidden = true
        }
    }
}

struct HiddenNavigationTitleStyleStyle_Previews: PreviewProvider {
    struct SecondScreen: View {
        @Environment(\.dismiss)
        private var dismiss

        var body: some View {
            Button("Dismiss", action: dismiss.callAsFunction)
                .navigationTitle("Second")
        }
    }

    static var previews: some View {
        NavigationView {
            NavigationLink("Push", destination: SecondScreen())
                .hiddenNavigationTitle()
                .navigationTitle("Home")
        }.navigationViewStyle(StackNavigationViewStyle())

    }
}

#endif
