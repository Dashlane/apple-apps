import Foundation

public protocol AlertProtocol {

  var title: String { get }
  var description: AlertSection? { get }
  var details: AlertSection? { get }
  var recommendation: AlertSection? { get }

  var buttons: Buttons { get }

  var breach: Breach { get }
  var data: AlertGenerator.AlertData { get }
}

extension AlertProtocol {
  public var breach: Breach {
    return data.breach
  }
}
