import Foundation

public protocol PopupAlertProtocol: AlertProtocol {

}

extension PopupAlertProtocol where Self == DashlaneSixPopupAlert {
  public static var mock: DashlaneSixPopupAlert {
    DashlaneSixPopupAlert(
      title: "A popup alert",
      description: .init(title: .init("_"), contents: ["Data"]),
      details: .init(title: .init("_"), contents: ["Data Detail"]),
      recommendation: .init(title: .init("_"), contents: ["Recomendation"]),
      buttons: .init(left: .cancel, right: .view),
      data: .init(breach: .mock, alertType: .publicAlert))
  }
}
