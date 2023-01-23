#if canImport(UIKit)

import Foundation
import SwiftUI

public extension NavigationLink where Label == EmptyView {
        init(isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) {
        self.init(destination: destination(), isActive: isActive) {
            EmptyView()
        }
    }
    
        init<Tag>(tag: Tag,  selection: Binding<Tag?>, @ViewBuilder destination: () -> Destination) where Tag: Hashable {
        self.init(destination: destination(), tag: tag, selection: selection) {
            EmptyView()
        }
    }
    
        init<Item, EmbeddedDestination>(item: Binding<Item?>, @ViewBuilder destination: (Item) -> EmbeddedDestination) where Destination == EmbeddedDestination? {
        let binding = Binding<Bool>(get: {
            item.wrappedValue != nil
        }, set: { isActive in
            if !isActive {
                item.wrappedValue = nil
            }
        })

        self.init(isActive: binding) {
            if let item = item.wrappedValue {
                destination(item)
            }
        }
    }
}


public extension View {
        func navigation<Destination: View>(isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) -> some View {
        self
            .background(
                NavigationLink(isActive: isActive,
                               destination: destination)
                .accessibilityHidden(true)
            )
    }
    
        func navigation<Tag, Destination>(tag: Tag,  selection: Binding<Tag?>, @ViewBuilder destination: () -> Destination) -> some View where Destination: View, Tag: Hashable {
        self
            .background(
                NavigationLink(tag: tag,
                               selection: selection,
                               destination: destination)
                .accessibilityHidden(true)
            )
    }
    
        func navigation<Item, Destination>(item: Binding<Item?>, @ViewBuilder destination: (Item) -> Destination) -> some View where Destination: View {
        self
            .background(
                NavigationLink(item: item,
                               destination: destination)
                .accessibilityHidden(true)

            )
    }
}


struct NavigationLinkProgrammaticPush_Previews: PreviewProvider {
    struct IsActiveBindingScreen: View {
        @State
        var isSecondScreenDisplayed: Bool = false
        
        var body: some View {
            NavigationView {
                Button("Push programatically") {
                    isSecondScreenDisplayed = true
                }
                .navigationTitle("Boolean Binding")
                .navigation(isActive: $isSecondScreenDisplayed) {
                    SecondScreen()
                }
            }
        }
    }
    
    struct SelectionBindingScreen: View {
        enum Step: Hashable {
            case firstStep
            case secondStep
        }
        @State
        var step: Step? = .firstStep
        
        var body: some View {
            NavigationView {
                Button("Push programatically") {
                    step = .secondStep
                }
                .navigationTitle("Selection Binding")
                .navigation(tag: .secondStep, selection: $step) {
                    SecondScreen()
                }
            }
        }
    }
    
    struct ItemBindingScreen: View {
        @State
        var text: String? = nil
        
        var body: some View {
            NavigationView {
                Button("Push programatically") {
                    text = "Hello World"
                }
                .navigationTitle("Item Binding")
                .navigation(item: $text) { text in
                    Text(text)
                }
            }
        }
    }
    
    struct SecondScreen: View {
        @Environment(\.dismiss)
        private var dismiss
        
        var body: some View {
            Button("Dismiss", action: dismiss.callAsFunction)
                .navigationTitle("Second")
        }
    }
    
    static var previews: some View {
        IsActiveBindingScreen()
            .previewDisplayName("Push by boolean binding")
        SelectionBindingScreen()
            .previewDisplayName("Push by selection tag binding")
        ItemBindingScreen()
            .previewDisplayName("Push by optional item binding")
    }
}
#endif
