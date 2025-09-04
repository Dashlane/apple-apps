import Foundation
import SwiftUI

public struct StepBasedNavigationView<Step, Content>: View where Content: View {
  @Binding
  var steps: [Step]

  let content: (Step) -> Content

  public init(steps: Binding<[Step]>, @ViewBuilder content: @escaping (Step) -> Content) {
    _steps = steps
    self.content = content
  }

  public var body: some View {
    NavigationView {
      StepBasedContentNavigationView(steps: $steps, content: content)
    }.navigationViewStyle(.stack)
  }
}

public struct StepBasedContentNavigationView<Step, Content>: View where Content: View {
  @Binding
  var steps: [Step]

  let content: (Step) -> Content

  public init(steps: Binding<[Step]>, @ViewBuilder content: @escaping (Step) -> Content) {
    _steps = steps
    self.content = content
  }

  public init(steps: [Step], @ViewBuilder content: @escaping (Step) -> Content) {
    _steps = .constant(steps)
    self.content = content
  }

  public var body: some View {
    if !steps.isEmpty {
      NavigationStepContentView(content: content, stepIndex: 0, steps: $steps)
    }
  }
}

private struct NavigationStepContentView<Step, Content>: View where Content: View {
  let content: (Step) -> Content
  let stepIndex: Int
  @Binding
  var steps: [Step]

  var nextViewBinding: Binding<Bool> {
    let nextIndex = stepIndex + 1
    return Binding<Bool>(
      get: {
        return nextIndex < steps.count
      },
      set: { isActive in
        if !isActive && nextIndex == (steps.count - 1) {
          _ = steps.popLast()
        }
      })
  }

  var body: some View {
    if steps.count > stepIndex {
      content(steps[stepIndex])
        .navigation(isActive: nextViewBinding) {
          NavigationStepContentView(
            content: content,
            stepIndex: stepIndex + 1,
            steps: $steps)
        }
    }
  }

}

struct StepBasedNavigationView_Previews: PreviewProvider {
  enum Step: String, CaseIterable {
    case stepA
    case stepB
  }

  struct BaseTestView: View {
    @State
    var steps: [Step] = [.stepA]

    var body: some View {
      StepBasedNavigationView(steps: $steps) { step in
        VStack {
          Text(step.rawValue)
          Button("Next Random") {
            steps.append(.allCases.randomElement() ?? .stepA)
          }
        }
      }
    }
  }

  struct EmbeddedFlowTestView: View {
    @State
    var steps: [Step] = [.stepA]

    var body: some View {
      StepBasedNavigationView(steps: $steps) { step in
        VStack {
          switch step {
          case .stepA:
            Button("Push current flow subflow") {
              self.steps.append(.stepA)
            }
            Button("Start subflow") {
              self.steps.append(.stepB)
            }
            .navigationTitle(.init(step.rawValue))
          case .stepB:
            SubFlowView()
              .navigationTitle(.init(step.rawValue))
          }
        }
      }
    }
  }

  private struct SubFlowView: View {
    enum SubFlowStep: String, CaseIterable {
      case step1
      case step2
    }

    @State
    var subSteps: [SubFlowStep] = [.step1]

    var body: some View {
      StepBasedContentNavigationView(steps: $subSteps) { step in
        VStack {
          Text("SubFlow \(step.rawValue)")
          Button("Next Random") {
            subSteps.append(.allCases.randomElement() ?? .step1)
          }.navigationTitle(.init(step.rawValue))

        }
      }
    }
  }

  static var previews: some View {
    BaseTestView()
    EmbeddedFlowTestView()
  }
}
