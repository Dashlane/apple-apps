import DesignSystem
import SwiftUI
import UIDelight

struct SlotMachineText: View {
  private struct AnimatedCharacter {
    let value: Character
    let direction: Edge
    let delay: Double
  }

  static let separatorColor = Color.gray.opacity(0.4)

  let password: String

  private let selectionGenerator = UserFeedbackGenerator.makeSelectionFeedbackGenerator()

  @State
  private var animatedPassword: [AnimatedCharacter] = []

  @State
  private var shouldDisplaySeparator: Bool = false

  @State
  private var workItem: DispatchWorkItem?

  private static let maskGradient = Gradient(colors: [
    Color.white.opacity(0),
    Color.white,
    Color.white,
    Color.white.opacity(0),
  ])

  private let columns: [GridItem] = [
    GridItem(.adaptive(minimum: 13, maximum: 13), spacing: -0.5)
  ]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 0) {
      ForEach(animatedPassword.indices, id: \.self) { index in
        let character = animatedPassword[index]
        ZStack {
          ColoredCharacter(character.value)
            .frame(height: 30)
            .transition(.rollingTransition(withDirection: character.direction))
            .id(character.value)
        }
        .animation(
          Animation
            .interpolatingSpring(
              mass: 0.3,
              stiffness: 40,
              damping: 8,
              initialVelocity: 0
            )

            .delay(character.delay), value: character.value
        )
        .padding(.vertical, 10)
        .background(characterBackground)
        .mask(mask)
      }

    }
    .accessibilityElement(children: .combine)
    .frame(maxHeight: .infinity)
    .animation(.easeInOut, value: password.count)
    .animation(.easeOut, value: shouldDisplaySeparator)
    .onChange(of: password) { _, newValue in
      animate(to: newValue)
    }
    .onAppear(perform: {
      animate(to: password)
    })
  }

  private var separator: some View {
    Rectangle()
      .foregroundStyle(Self.separatorColor)
      .frame(width: 0.5)

  }

  @ViewBuilder
  private var characterBackground: some View {
    if shouldDisplaySeparator {
      HStack {
        separator
        Spacer()
        separator
      }
    }
  }

  @ViewBuilder
  private var mask: some View {
    LinearGradient(gradient: Self.maskGradient, startPoint: .top, endPoint: .bottom)
  }

  private func animate(to newPassword: String) {
    let currentlyDisplayed = String(animatedPassword.map { $0.value })
    guard currentlyDisplayed != newPassword else {
      return
    }
    let newPassword = Array(newPassword)

    selectionGenerator.prepare()

    let shuffledPassword = Array(newPassword.shuffled())
    self.animatedPassword = newPassword.indices.map { index in
      AnimatedCharacter(
        value: shuffledPassword[index],
        direction: [Edge.top, Edge.bottom].randomElement() ?? .top,
        delay: Double.random(in: 0..<0.5))
    }

    shouldDisplaySeparator = true

    dispatchAfter(0.2) {
      self.animatedPassword = newPassword.indices.map { index in
        let character = animatedPassword.count > index ? animatedPassword[index] : nil

        return AnimatedCharacter(
          value: newPassword[index],
          direction: character?.direction ?? .top,
          delay: character?.delay ?? 0)
      }

      selectionGenerator.selectionChanged()

      dispatchAfter(0.4) {
        shouldDisplaySeparator = false
        selectionGenerator.selectionChanged()
      }
    }
  }

  private func dispatchAfter(_ delay: Double, block: @escaping () -> Void) {
    workItem?.cancel()
    let workItem = DispatchWorkItem(block: block)

    self.workItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }
}

extension AnyTransition {
  fileprivate static func rollingTransition(withDirection direction: Edge) -> AnyTransition {
    AnyTransition.asymmetric(
      insertion: .move(edge: direction),
      removal: .move(edge: direction == .top ? .bottom : .top)
    )
    .combined(with: .opacity)
  }
}

private struct ColoredCharacter: View {
  let character: Character
  init(_ character: Character) {
    self.character = character
  }

  var body: some View {
    Text(String(character))
      .font(.system(size: 21).monospaced())
      .lineLimit(1)
      .minimumScaleFactor(0.3)
      .foregroundStyle(Color(passwordCharacter: character))
  }
}

#Preview("Short Password", traits: .sizeThatFitsLayout) {
  SlotMachineText(password: "t3st")
    .background(.ds.container.agnostic.neutral.standard)
    .frame(width: 200, height: 200)
}

#Preview("Long Password", traits: .sizeThatFitsLayout) {
  SlotMachineText(password: "t3stsup3rm3g4l0ngt123stsup3rm3g4l0ng")
    .background(.ds.container.agnostic.neutral.standard)
    .frame(width: 200, height: 200)
}
