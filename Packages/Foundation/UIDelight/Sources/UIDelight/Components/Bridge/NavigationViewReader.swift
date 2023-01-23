#if canImport(UIKit)

import Foundation
import SwiftUI

public struct NavigationViewReader<Content: View>: View {
    @State
    private var proxy: NavigationViewProxy?
    
    let content: (NavigationViewProxy) -> Content
    
    public init(@ViewBuilder content: @escaping (NavigationViewProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if let proxy = proxy {
                content(proxy)
            } else {
                NavigationControllerCaptureView { navigationController in
                    self.proxy = UIKitNavigationViewProxy(navigationController: navigationController)
                }
            }
        }
    }
}

public protocol NavigationViewProxy {
    func push<V>(_ viewController: V, animated: Bool) where V: UIViewController
    func push<V>(_ view: V, animated: Bool) where V: View
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
}

public extension NavigationViewProxy {
    func push<V>(_ viewController: V) where V: UIViewController {
        push(viewController, animated: true)
    }
    
    func push<V>(_ view: V) where V: View {
        push(view, animated: true)
    }
    
    func pop() {
        pop(animated: true)
    }
    
    func popToRoot() {
        pop(animated: true)
    }
}

struct UIKitNavigationViewProxy: NavigationViewProxy {
            weak var navigationController: UINavigationController?
    
    public func push<V>(_ view: V, animated: Bool) where V : View {
        navigationController?.pushViewController(UIHostingController(rootView: view), animated: animated)
    }
    
    public func push<V>(_ viewController: V, animated: Bool) where V : UIViewController {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    public func pop(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    public func popToRoot(animated: Bool) {
        navigationController?.popToRootViewController(animated: animated)
    }
}


private struct NavigationControllerCaptureView: UIViewControllerRepresentable {
    let inspect: (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> NavigationBarProxyCaptureViewController {
        NavigationBarProxyCaptureViewController(inspect: inspect)
    }

    func updateUIViewController(_ uiViewController: NavigationBarProxyCaptureViewController, context: Context) {

    }
}

private final class NavigationBarProxyCaptureViewController: UIViewController {
    let inspect: (UINavigationController) -> Void
    
    init(inspect: @escaping (UINavigationController) -> Void) {
        self.inspect = inspect
        super.init(nibName: nil, bundle: nil)
        self.view = UIView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let navigation = self.navigationController else {
            return
        }
        inspect(navigation)
    }
}


struct NavigationViewReader_Previews: PreviewProvider {
    struct SecondScreen: View {
        var body: some View {
            NavigationViewReader { proxy in
                Button("Pop") {
                    proxy.pop()
                }
                
            }
        }
    }
    
    static var previews: some View {
        NavigationView {
            NavigationViewReader { proxy in
                Button("Push") {
                    proxy.push(SecondScreen())
                }
            }
        }
    }
}

#endif
