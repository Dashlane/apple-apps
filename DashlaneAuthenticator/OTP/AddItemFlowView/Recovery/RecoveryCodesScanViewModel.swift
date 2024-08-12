import Foundation
import UIKit
import Vision

class RecoveryCodesScanViewModel: ObservableObject {

  @Published
  var isCameraAlertErrorPresented: Bool = false
  @Published
  var isProgress: Bool = false

  @Published
  var presentConfirmation = false

  @Published
  var recoveryCodes: [String] = []

  let save: ([String]) -> Void
  let cancel: () -> Void
  init(save: @escaping ([String]) -> Void, cancel: @escaping () -> Void) {
    self.save = save
    self.cancel = cancel
  }

  lazy var textRecognitionRequest: VNRecognizeTextRequest = {
    let request = VNRecognizeTextRequest(completionHandler: { (request, _) in
      if let results = request.results, !results.isEmpty {
        if let requestResults = request.results as? [VNRecognizedTextObservation] {
          var fullText = ""
          let maximumCandidates = 1
          for observation in requestResults {
            guard let candidate = observation.topCandidates(maximumCandidates).first else {
              continue
            }
            fullText.append(candidate.string + "\n")
          }
          DispatchQueue.main.async {
            self.isProgress = false
            if fullText.isEmpty {
              self.isCameraAlertErrorPresented = true
            } else {
              self.recoveryCodes = fullText.split(separator: "\n").compactMap {
                let code = $0.trimmingCharacters(in: CharacterSet.whitespaces)
                if code.isEmpty {
                  return nil
                }
                return code
              }
              self.presentConfirmation = true
            }
          }
        }
      }
    })
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    return request
  }()

  func processImage(_ image: UIImage) {
    isProgress = true
    DispatchQueue.global(qos: .userInitiated).async {
      guard let cgImage = image.cgImage else {
        print("Failed to get cgimage from input image")
        return
      }
      let handler = VNImageRequestHandler(cgImage: cgImage)
      do {
        try handler.perform([self.textRecognitionRequest])
      } catch {
        print(error)
      }
    }
  }
}
