import Foundation
import Cocoa
import SwiftUI

final class MenuViewController<V: View>: NSViewController {
    
    let elements: [[MenuItem]]
    let selected: (MenuItem) -> Void
    let label: NSHostingView<V>
    
    init(label: NSHostingView<V>,
         elements: [[MenuItem]],
         selected: @escaping (MenuItem) -> Void) {
        self.label = label
        self.elements = elements
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(showMenu))
        label.addGestureRecognizer(clickGesture)
        self.view = label
    }
    
    @objc func showMenu() {
        let menu = NSMenu(title: "")
        
        let items = elements.reduce(into: [NSMenuItem]()) { (result, items) in
            if !result.isEmpty {
                result.append(NSMenuItem.separator())
            }
            let menuItems = items.map { NSMenuItem(title: $0.menuTitle,
                                                   action: $0.canPerformAction ? #selector(selectedItem(_:)) : nil,
                                                   keyEquivalent: "")}
            result.append(contentsOf: menuItems)
        }
        
        items.forEach {
            $0.target = self
            menu.addItem($0)
        }
        let p = NSPoint(x: 0, y: label.frame.height)
        menu.popUp(positioning: items.first, at: p, in: self.view)
    }
    
    @objc func selectedItem(_ sender: NSMenuItem) {
        let item = elements
            .flatMap { $0 }
            .first(where: { $0.menuTitle == sender.title })
        guard let unwrapped = item else {
            return
        }
        selected(unwrapped)
    }
}

protocol MenuItem {
    var menuTitle: String { get }
    var canPerformAction: Bool { get }
}

struct MenuView<V: View>: NSViewControllerRepresentable {

    let label: NSHostingView<V>
    let elements: [[MenuItem]]
    let selected: (MenuItem) -> Void
    
    init(label: V,
         elements: [[MenuItem]],
         selected: @escaping (MenuItem) -> Void) {
        self.label = NSHostingView(rootView: label)
        self.elements = elements
        self.selected = selected
    }

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<MenuView>
    ) -> MenuViewController<V> {
        return MenuViewController(label: label,
                                  elements: elements,
                                  selected: selected)
    }
    
    func updateNSViewController(
        _ nsViewController: MenuViewController<V>,
        context: NSViewControllerRepresentableContext<MenuView>
    ) {

    }
}
