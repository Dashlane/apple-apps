#if canImport(UIKit)

import Foundation
import SwiftUI
import Combine


public struct PopNavigationLink<Label>: View where Label: View {
    public enum Action {
                case pop
                case popToRoot
    }
    
    @State
    private var actionPublisher = PassthroughSubject<Action, Never>()

    public let action: Action
    public let label: Label

    @BindingOrState
    private var isActive: Bool
    
        public init(action: Action = .pop, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
        self._isActive = .init(wrappedValue: false)
    }
    
        public init(isActive: Binding<Bool>, action: Action = .pop, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
        self._isActive = .init(isActive)
    }
    
        public init<Tag>(tag: Tag,  selection: Binding<Tag?>, action: Action = .pop, @ViewBuilder label: () -> Label) where Tag: Hashable {
        self.action = action
        self.label = label()
        self._isActive = .init(Binding(get: {
            return selection.wrappedValue == tag
        }, set: { active in
            selection.wrappedValue = active ? tag : nil
        }))
    }
    
    public var body: some View {
        Button {
            isActive = true
        } label: {
            label
        }
        .onChange(of: isActive, perform: { newValue in
            guard newValue else {
                return
            }
            actionPublisher.send(action)
        })
        .background(PopRootViewWrapper(actionPublisher: actionPublisher))
    }
}
     
public extension PopNavigationLink where Label == Text {
        init(_ text: String, action: Action = .pop) {
        self.init(action: action, label: {
            Text(text)
        })
    }
    
        init(_ text: String, isActive: Binding<Bool>, action: Action = .pop) {
        self.init(isActive: isActive, action: action, label: {
            Text(text)
        })
    }
    
        init<Tag>(_ text: String, tag: Tag,  selection: Binding<Tag?>, action: Action = .pop) where Tag: Hashable {
        self.init(tag: tag, selection: selection, action: action, label: {
            Text(text)
        })
    }
}

public extension PopNavigationLink where Label == EmptyView {
        init(action: Action = .pop) {
        self.init(action: action, label: {
            EmptyView()
        })
    }
    
        init(isActive: Binding<Bool>, action: Action = .pop) {
        self.init(isActive: isActive, action: action, label: {
            EmptyView()
        })
    }
    
        init<Tag>(tag: Tag,  selection: Binding<Tag?>, action: Action = .pop) where Tag: Hashable {
        self.init(tag: tag, selection: selection, action: action, label: {
            EmptyView()
        })
    }
}

private struct PopRootViewWrapper<Label: View>: UIViewControllerRepresentable {
    let actionPublisher: PassthroughSubject<PopNavigationLink<Label>.Action, Never>
    
    func makeUIViewController(context: Context) -> PoppingActionViewController<Label> {
        PoppingActionViewController(actionPublisher: actionPublisher)
    }
    
    func updateUIViewController(_ uiViewController: PoppingActionViewController<Label>, context: Context) {
        
    }
}


private final class PoppingActionViewController<Label: View>: UIViewController {
    var subscription: AnyCancellable?
    
    init(actionPublisher: PassthroughSubject<PopNavigationLink<Label>.Action, Never>) {
        super.init(nibName: nil, bundle: nil)
        self.view = UIView()
        subscription = actionPublisher
            .sink { [weak self] action in
                self?.perform(action)
            }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func perform(_ action: PopNavigationLink<Label>.Action) {
        switch action {
            case .pop:
                self.navigationController?.popViewController(animated: true)
            case .popToRoot:
                self.navigationController?.navigationBar.backgroundColor = .red
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

struct PopNavigationLink_Previews: PreviewProvider {
    struct SecondScreen: View {
        var body: some View {
            PopNavigationLink("Pop")
                .navigationTitle("Second")
        }
    }
    
    static var previews: some View {
        NavigationView {
            NavigationLink("Push", destination: SecondScreen())
                .navigationTitle("Home")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
#endif
