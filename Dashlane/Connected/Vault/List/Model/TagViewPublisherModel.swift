import Combine
import Foundation

class TagViewPublisherModel: ObservableObject {

  @Published
  var isHidden: Bool = true

  @Published
  var message: String = ""

  private var cancellables = Set<AnyCancellable>()

  init(tagMessage: AnyPublisher<String?, Never>?) {
    guard let tagMessage = tagMessage else {
      return
    }
    tagMessage
      .receive(on: RunLoop.main)
      .sink { [weak self] tagMessage in
        if let tagMessage = tagMessage {
          self?.isHidden = false
          self?.message = tagMessage
        } else {
          self?.isHidden = true
        }

      }.store(in: &cancellables)
  }
}
