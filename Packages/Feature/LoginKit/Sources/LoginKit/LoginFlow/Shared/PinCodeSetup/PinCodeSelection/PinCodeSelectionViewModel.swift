import Foundation

public class PinCodeSelectionViewModel: ObservableObject {

  public typealias PinCodeSelectionCompletion = (String?) -> Void
  let completion: PinCodeSelectionCompletion

  @Published
  var pincode: String = "" {
    didSet {
      if pincode.count == pinCodeLength {
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
          self.stepCompleted(submittedCode: self.pincode)
        }
      }
    }
  }

  @Published
  var failedAttempts: Int = 0

  @Published
  var pinCodeLength: Int = 6 {
    didSet {
      pincode = ""
    }
  }

  public init(
    currentPin: String? = nil,
    completion: @escaping PinCodeSelectionCompletion
  ) {
    if let currentPin = currentPin {
      current = .verify(currentPin: currentPin)
    } else {
      current = .select
    }
    self.completion = completion
  }

  func stepCompleted(submittedCode: String) {
    pincode = ""
    let isValid = validateStep(submittedCode: submittedCode)
    guard isValid else {
      failedAttempts += 1
      return
    }
    guard let nextStep = current.next(code: submittedCode) else {
      completion(submittedCode)
      return
    }
    current = nextStep
    return
  }

  func validateStep(submittedCode: String) -> Bool {
    switch current {
    case .verify(let currentPin):
      return currentPin == submittedCode
    case .select:
      return true
    case .confirm(let selectedPin):
      return selectedPin == submittedCode
    }
  }

  func cancel() {
    completion(nil)
  }

  enum Step {
    case verify(currentPin: String)
    case select
    case confirm(selectedPin: String)

    func next(code: String) -> Step? {
      switch self {
      case .verify:
        return .select
      case .select:
        return .confirm(selectedPin: code)
      case .confirm:
        return nil
      }
    }
  }

  @Published
  var current: Step

}
