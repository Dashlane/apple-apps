import Foundation
import SwiftUI
import Combine

private class ScrollEventListener {
    @Binding
    private var isScrolling: Bool
    
    @Binding
    var isOnTop: Bool

    let isScrollingPublisher = PassthroughSubject<Bool, Never>()
    let isOnTopPubliScrollingPublisher = PassthroughSubject<Bool, Never>()

    private var cancellables = Set<AnyCancellable>()
       
    init(isScrolling: Binding<Bool>?,
         isOnTop: Binding<Bool>?) {
        self._isScrolling = isScrolling ?? .constant(false)
        self._isOnTop = isOnTop ?? .constant(false)
        isScrollingPublisher
            .removeDuplicates()
            .sink {
                self.isScrolling = $0
            }.store(in: &cancellables)
    }
}

public struct TrackableScrollView<Content: View>: View {
    
    private let content: Content
    
    private let detector = PassthroughSubject<Int, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(isScrolling: Binding<Bool>? = nil,
                isOnTop: Binding<Bool>? = nil,
                content: () -> Content) {
        self.content = content()
        
        let listener = ScrollEventListener(isScrolling: isScrolling, isOnTop: isOnTop)
        if isScrolling != nil {
        detector
            .dropFirst()
            .map({ _ in
                listener.isScrollingPublisher.send(true)
            })
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink(receiveValue: {
                listener.isScrollingPublisher.send(false)
            }).store(in: &cancellables)
        }
        if isOnTop != nil {
            detector
                .map({ $0 <= 0 })
                .removeDuplicates()
                .sink(receiveValue: {
                    listener.isOnTop = $0
                }).store(in: &cancellables)
        }
    }
    
    public var body: some View {
        ScrollView {
            content
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) {
                    detector.send(Int($0))
                }
        }
        .coordinateSpace(name: "scroll")
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct TrackableScollView_Previews: PreviewProvider {
    
    struct Example: View {
        
        @State
        var isScrolling: Bool = false
        
        @State
        var isOnTop: Bool = false
        
        var body: some View {
            TrackableScrollView(isScrolling: $isScrolling, isOnTop: $isOnTop) {
                Group {
                    Text("Is scrolling \(String(isScrolling))")
                    VStack {
                        ForEach(0..<20) { index in
                            Text("Row \(index)")
                                .frame(height: 60)
                        }
                    }.background(isScrolling ? Color.blue : Color.red)
                }
            }
        }
    }
    
    static var previews: some View {
        Example()
    }
}
